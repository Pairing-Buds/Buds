// 인증 관련 API 통신

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // 로그인
  Future<User> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post(
        ApiConstants.loginUrl,
        data: data,
      );

      // 토큰 저장
      final token = response['token'];
      final user = User.fromJson(response['user']);

      await _saveToken(token);
      _apiService.setToken(token);

      return user;
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logoutUrl);
      await _clearToken();
      _apiService.clearToken();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  // 사용자 프로필 조회
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfileUrl);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }

  // 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // 토큰 읽기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // 토큰 삭제
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }
}
