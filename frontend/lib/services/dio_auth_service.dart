// Dio를 사용한 인증 관련 API 통신

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'dio_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class DioAuthService {
  final DioApiService _apiService = DioApiService();

  // 로그인
  Future<User> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Dio로 로그인 시도: $email');
        print('로그인 URL: ${ApiConstants.loginUrl}');
      }

      final data = {'userEmail': email, 'password': password};

      if (kDebugMode) {
        print('로그인 요청 데이터: $data');
      }

      // 응답에 쿠키 헤더 포함하도록 설정
      final dioOptions = Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        // 쿠키를 받기 위한 설정
        receiveDataWhenStatusError: true,
      );

      final response = await _apiService.post(
        ApiConstants.loginUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
        options: dioOptions,
      );

      if (kDebugMode) {
        print('로그인 응답: $response');
        if (response is Response) {
          print('응답 헤더: ${response.headers}');
          print('쿠키: ${response.headers['set-cookie']}');
        }
      }

      // 쿠키에서 토큰 추출
      String? accessToken;
      String? refreshToken;

      if (response is Response && response.headers['set-cookie'] != null) {
        // 쿠키 목록 가져오기
        final cookies = response.headers['set-cookie'];

        if (kDebugMode) {
          print('받은 쿠키: $cookies');
        }

        // 쿠키 파싱
        for (String cookie in cookies!) {
          if (cookie.contains('access_token=')) {
            accessToken = _extractTokenFromCookie(cookie, 'access_token=');
          } else if (cookie.contains('refresh_token=')) {
            refreshToken = _extractTokenFromCookie(cookie, 'refresh_token=');
          }
        }

        if (kDebugMode) {
          print('추출한 access_token: $accessToken');
          print('추출한 refresh_token: $refreshToken');
        }
      }

      // response.data에서도 토큰 확인 (일부 서버는 응답 본문에도 토큰을 보냄)
      if (accessToken == null &&
          response is Response &&
          response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // 1. 기본 형식: response['token']
        if (responseData['token'] != null) {
          accessToken = responseData['token'];
        }
        // 2. 기본 형식: response['accessToken']
        else if (responseData['accessToken'] != null) {
          accessToken = responseData['accessToken'];
          if (responseData['refreshToken'] != null) {
            refreshToken = responseData['refreshToken'];
          }
        }
        // 3. data 객체 내에 있는 경우
        else if (responseData['data'] != null &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data['accessToken'] != null) {
            accessToken = data['accessToken'];
            if (data['refreshToken'] != null) {
              refreshToken = data['refreshToken'];
            }
          } else if (data['token'] != null) {
            accessToken = data['token'];
          }
        }
      }

      if (accessToken == null) {
        throw Exception('응답에서 토큰을 찾을 수 없습니다');
      }

      // 기본 사용자 객체 생성 (이메일 기반)
      final user = User(
        id: 0,
        email: email,
        name: email.split('@')[0], // 이메일에서 추출한 기본 이름
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );

      // 토큰 저장
      await _apiService.setToken(accessToken);

      // 리프레시 토큰이 있으면 따로 저장
      if (refreshToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('refresh_token', refreshToken);
      }

      if (kDebugMode) {
        print('로그인 성공: ${user.email}');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('로그인 요청 오류: $e');
      }
      throw Exception('로그인 실패: $e');
    }
  }

  // 쿠키에서 토큰 값 추출하는 헬퍼 함수
  String? _extractTokenFromCookie(String cookie, String tokenKey) {
    final int startIndex = cookie.indexOf(tokenKey) + tokenKey.length;
    int endIndex = cookie.indexOf(';', startIndex);

    // 세미콜론이 없는 경우 (마지막 쿠키)
    if (endIndex == -1) {
      endIndex = cookie.length;
    }

    return cookie.substring(startIndex, endIndex);
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

      if (response is Response && response.data != null) {
        return User.fromJson(response.data);
      }

      throw Exception('프로필 데이터를 찾을 수 없습니다');
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
