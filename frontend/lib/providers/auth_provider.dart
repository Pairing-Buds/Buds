// 인증 상태 관리
import 'package:flutter/material.dart';
import 'package:buds/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  // 로그인 처리 중 상태
  bool _isLoading = false;

  // 이메일 인증 코드
  String _verificationCode = '';

  final DioAuthService _authService = DioAuthService();
  final DioApiService _apiService = DioApiService();

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String get verificationCode => _verificationCode;

  // 추가: 사용자가 익명인지 확인하는 getter
  bool get isAnonymousUser {
    if (_userData == null) {
      if (kDebugMode) {
        print('isAnonymousUser: userData가 null입니다.');
      }
      return false;
    }

    if (kDebugMode) {
      print('isAnonymousUser 확인 중: ${_userData}');
      print('사용자 이름: ${_userData!['name']}');
    }

    return _userData!['name'] == '익명';
  }

  // 로딩 상태 설정
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('AuthProvider 초기화 시작...');
      }

      // 먼저 저장된 쿠키가 있는지 확인
      bool hasStoredCookies = false;
      try {
        hasStoredCookies = await _apiService.checkSavedCookies();
        if (kDebugMode) {
          print('저장된 쿠키 확인 결과: $hasStoredCookies');
        }
      } catch (e) {
        if (kDebugMode) {
          print('저장된 쿠키 확인 중 오류: $e');
        }
      }

      // 저장된 쿠키가 있거나 서버에서 쿠키 유효성 검증이 성공하면 로그인 상태로 처리
      final cookiesValid =
          hasStoredCookies || await _authService.checkCookies();

      if (cookiesValid) {
        _isLoggedIn = true;
        try {
          // 사용자 프로필 정보 로드
          final user = await _authService.getUserProfile();
          _userData = user.toJson();
          if (kDebugMode) {
            print('사용자 인증 상태 확인: 로그인됨 (${user.email})');
          }
        } catch (e) {
          if (kDebugMode) {
            print('사용자 프로필 로드 오류: $e');
            print('쿠키는 유효하지만 사용자 데이터를 가져올 수 없습니다. 로그인 상태는 유지됩니다.');
          }
        }
      } else {
        _isLoggedIn = false;
        if (kDebugMode) {
          print('사용자 인증 상태 확인: 로그아웃됨 (쿠키 없음)');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('인증 상태 초기화 오류: $e');
      }
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // 사용자 정보 새로고침
  Future<void> refreshUserData() async {
    try {
      if (!_isLoggedIn) {
        if (kDebugMode) {
          print('사용자가 로그인되어 있지 않습니다. 정보를 가져올 수 없습니다.');
        }
        return;
      }

      final user = await _authService.getUserProfile();
      _userData = user.toJson();

      if (kDebugMode) {
        print('사용자 정보 새로고침 완료: ${user.email}, 이름: ${user.name}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('사용자 정보 새로고침 오류: $e');
      }
      throw e; // 오류를 다시 던져서 호출자가 처리할 수 있게 함
    }
  }

  // 로그인 처리
  Future<bool> login(String email, String password) async {
    setLoading(true);

    try {
      if (kDebugMode) {
        print('로그인 시도: $email');
      }

      // Dio를 사용한 로그인 처리
      final user = await _authService.login(email, password);

      // 사용자 정보 저장
      _userData = user.toJson();
      _isLoggedIn = true;

      notifyListeners();
      return true;
    } catch (e) {
      _isLoggedIn = false;
      if (kDebugMode) {
        print('로그인 오류: $e');
      }
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    setLoading(true);

    try {
      // 서버에 로그아웃 요청
      await _authService.logout();
    } catch (e) {
      if (kDebugMode) {
        print('로그아웃 요청 오류: $e');
      }
    } finally {
      // 로컬 상태 초기화
      _isLoggedIn = false;
      _userData = null;
      notifyListeners();
      setLoading(false);
    }
  }

  // 비밀번호 재설정 이메일 요청 - 기존 메소드
  Future<bool> requestPasswordReset(String email) async {
    try {
      if (kDebugMode) {
        print('비밀번호 재설정 이메일 요청 시작: $email');
      }

      return await _authService.requestPasswordReset(email);
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재설정 이메일 요청 오류: $e');
      }
      return false;
    }
  }

  // 비밀번호 재설정 - 기존 메소드
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      if (kDebugMode) {
        print('비밀번호 재설정 시작');
      }

      return await _authService.resetPassword(token, newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재설정 오류: $e');
      }
      return false;
    }
  }

  // 이메일 인증 코드 저장
  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }
}
