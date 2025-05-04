// Dio를 사용한 인증 관련 API 통신

import '../constants/api_constants.dart';
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

      // 응답에 쿠키 헤더 포함하도록 설정 (이제 자동으로 처리됨)
      final dioOptions = Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        receiveDataWhenStatusError: true,
      );

      final response = await _apiService.post(
        ApiConstants.loginUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
        options: dioOptions,
      );

      if (kDebugMode) {
        print('로그인 응답: ${response.data}');
        if (response is Response) {
          print('응답 헤더: ${response.headers}');
          print('쿠키: ${response.headers['set-cookie']}');
        }
      }

      // 응답 데이터에서 사용자 정보 추출 또는 기본 사용자 객체 생성
      User user;

      if (response is Response && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // 응답에 사용자 정보가 있는 경우
        if (responseData['user'] != null) {
          user = User.fromJson(responseData['user']);
        } else {
          // 사용자 정보가 없는 경우 기본 객체 생성
          user = User(
            id: 0,
            email: email,
            name: email.split('@')[0], // 이메일에서 추출한 기본 이름
            profileImageUrl: null,
            createdAt: DateTime.now(),
          );
        }
      } else {
        // 응답이 예상과 다른 경우 기본 객체 생성
        user = User(
          id: 0,
          email: email,
          name: email.split('@')[0],
          profileImageUrl: null,
          createdAt: DateTime.now(),
        );
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

      print('회원가입 응답 데이터: ${response.data}');

      // 응답 검증
      if (response is Response && response.data == null) {
        throw Exception('서버 응답이 없습니다');
      }

      final responseData = response is Response ? response.data : response;

      // 상태 코드 확인
      final statusCode = responseData['statusCode'];
      final resMsg = responseData['resMsg'];

      if (statusCode != 'CREATED' && statusCode != 'OK') {
        throw Exception('회원가입 실패: $resMsg');
      }

      // 회원가입 성공 시 기본 User 객체 반환
      return User(
        id: 0,
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
      await _apiService.clearCookies();
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
        final responseData = response.data as Map<String, dynamic>;

        if (kDebugMode) {
          print('getUserProfile 응답: $responseData');
        }

        // 서버 응답 구조 확인
        if (responseData['statusCode'] == 'OK' &&
            responseData['resMsg'] != null) {
          // resMsg 필드에서 데이터 추출하여 사용자 정보 생성
          final userData = responseData['resMsg'] as Map<String, dynamic>;

          return User(
            id: 0, // API에서 userId를 제공하지 않음
            email: userData['userEmail'] ?? '',
            name: userData['userName'] ?? '',
            profileImageUrl: null,
            createdAt: DateTime.now(),
          );
        }

        // 기존 방식으로 시도
        return User.fromJson(responseData);
      }

      throw Exception('프로필 데이터를 찾을 수 없습니다');
    } catch (e) {
      if (kDebugMode) {
        print('프로필 조회 실패: $e');
      }
      throw Exception('프로필 조회 실패: $e');
    }
  }

  // 쿠키 확인 (디버깅용)
  Future<bool> checkCookies() async {
    try {
      final response = await _apiService.get(
        ApiConstants.userProfileUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );

      return response is Response && response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('쿠키 확인 오류: $e');
      }
      return false;
    }
  }
}
