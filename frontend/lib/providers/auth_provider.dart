// 인증 상태 관리
import 'package:flutter/material.dart';
import 'package:buds/services/dio_auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  final DioAuthService _authService = DioAuthService();

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;

  // 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    try {
      // 쿠키 유효성 검증 (사용자 프로필 요청으로)
      final cookiesValid = await _authService.checkCookies();

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

  // 로그인 처리
  Future<bool> login(String email, String password) async {
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
      if (kDebugMode) {
        print('로그인 오류: $e');
      }
      return false;
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    try {
      // 서버에 로그아웃 요청
      await _authService.logout();
    } catch (e) {
      if (kDebugMode) {
        print('로그아웃 요청 오류: $e');
      }
    }

    // 로컬 상태 초기화
    _isLoggedIn = false;
    _userData = null;

    notifyListeners();
  }
}
