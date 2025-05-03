// Dio를 사용한 인증 관련 API 통신

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'dio_api_service.dart';

class DioAuthService {
  final DioApiService _apiService = DioApiService();

  // 로그인
  Future<User> login(String email, String password) async {
    try {
      final data = {'userEmail': email, 'password': password};

      final response = await _apiService.post(
        ApiConstants.loginUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
      );

      // 토큰 저장
      final token = response['token'];
      final user = User.fromJson(response['user']);

      await _apiService.setToken(token);

      return user;
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  // 회원가입
  Future<User> register(
    String name,
    String email,
    String password, {
    String? birthDate,
  }) async {
    try {
      final data = {
        'userEmail': email,
        'password': password,
        'birthDate': birthDate ?? '',
      };

      print('회원가입 요청 데이터: $data');

      final response = await _apiService.post(
        ApiConstants.registerUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
      );

      print('회원가입 응답 데이터: $response');

      // 응답 검증
      if (response == null) {
        throw Exception('서버 응답이 없습니다');
      }

      // 상태 코드 확인
      final statusCode = response['statusCode'];
      final resMsg = response['resMsg'];

      if (statusCode != 'CREATED' && statusCode != 'OK') {
        throw Exception('회원가입 실패: $resMsg');
      }

      // 회원가입 성공 시 기본 User 객체 반환
      // 실제 사용자 데이터는 없지만 회원가입이 성공했으므로 이메일 정보로 기본 객체 생성
      return User(
        id: 0, // 실제 ID는
        email: email,
        name: name.isEmpty ? email.split('@')[0] : name, // 이름이 없으면 이메일에서 추출
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('회원가입 프로세스 오류 세부 정보: $e');
      throw Exception('회원가입 실패: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _apiService.post(
        ApiConstants.logoutUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );
      await _apiService.clearToken();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  // 사용자 프로필 조회
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.userProfileUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );
      return User.fromJson(response);
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }

  // 토큰 읽기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}
