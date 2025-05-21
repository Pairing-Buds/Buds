// 인증 상태 관리

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:buds/services/auth_service.dart';
import '../constants/api_constants.dart';
import '../services/api_service.dart';

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
      return false;
    }

    return _userData!['name'] == '익명';
  }

  // 로딩 상태 설정
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 초기화 - 앱 시작 시 호출
  Future<void> initialize(BuildContext context) async {
    try {
      // 먼저 저장된 쿠키가 있는지 확인
      bool hasStoredCookies = false;
      try {
        hasStoredCookies = await _apiService.checkSavedCookies();
      } catch (e) {}

      if (hasStoredCookies) {
        try {
          // 사용자 프로필 정보 로드
          final user = await _authService.getUserProfile();
          _userData = user.toJson();
          _isLoggedIn = true;
        } catch (e) {
          // 프로필 로드 실패 시 로그아웃 처리
          _isLoggedIn = false;
          _userData = null;
          // 쿠키 삭제
          await _apiService.clearCookies();
          // 로그인 화면으로 이동
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      } else {
        _isLoggedIn = false;
      }

      notifyListeners();
    } catch (e) {
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // 사용자 정보 새로고침
  Future<void> refreshUserData() async {
    try {
      if (!_isLoggedIn) {
        return;
      }

      final user = await _authService.getUserProfile();
      _userData = user.toJson();

      notifyListeners();
    } catch (e) {
      throw e; // 오류를 다시 던져서 호출자가 처리할 수 있게 함
    }
  }

  // 로그인 처리
  Future<bool> login(String email, String password) async {
    setLoading(true);

    try {
      // Dio를 사용한 로그인 처리
      final user = await _authService.login(email, password);

      // 사용자 정보 저장
      _userData = user.toJson();
      _isLoggedIn = true;

      notifyListeners();
      return true;
    } catch (e) {
      _isLoggedIn = false;
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
      return await _authService.requestPasswordReset(email);
    } catch (e) {
      return false;
    }
  }

  // 비밀번호 재설정 - 기존 메소드
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      return await _authService.resetPassword(token, newPassword);
    } catch (e) {
      return false;
    }
  }

  // 이메일 인증 코드 저장
  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  // 사용자 캐릭터 업데이트
  Future<bool> updateUserCharacter(String userCharacter) async {
    try {
      setLoading(true);

      // 캐릭터 업데이트 API 호출
      final result = await _authService.updateUserCharacter(userCharacter);

      if (result) {
        // 성공적으로 업데이트되면 사용자 정보 새로고침
        await refreshUserData();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }
}
