// 인증 상태 관리
import 'package:flutter/material.dart';
import 'package:buds/services/dio_auth_service.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;

  final DioAuthService _authService = DioAuthService();

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userData => _userData;

  // 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    // 저장된 토큰이 있는지 확인
    await _loadTokens();

    // 토큰이 있으면 사용자 정보 로드
    if (_accessToken != null) {
      _isLoggedIn = true;
      try {
        // 사용자 프로필 정보 로드
        final user = await _authService.getUserProfile();
        _userData = user.toJson();
      } catch (e) {
        if (kDebugMode) {
          print('사용자 프로필 로드 오류: $e');
        }
      }
    }

    notifyListeners();
  }

  // 로그인 처리
  Future<bool> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('로그인 시도: $email');
      }

      // Dio를 사용한 로그인 처리
      final user = await _authService.login(email, password);

      // 토큰 가져오기
      _accessToken = await _authService.getToken();

      if (_accessToken != null) {
        // 사용자 정보 저장
        _userData = user.toJson();
        _isLoggedIn = true;

        // 리프레시 토큰도 로드
        final prefs = await SharedPreferences.getInstance();
        _refreshToken = prefs.getString('refresh_token');

        notifyListeners();
        return true;
      }
      return false;
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
    _accessToken = null;
    _refreshToken = null;
    _userData = null;

    // 저장된 토큰 삭제
    await _clearTokens();

    notifyListeners();
  }

  // 토큰 저장
  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
  }

  // 저장된 토큰 로드
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // 토큰 삭제
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
