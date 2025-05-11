// Dio를 사용한 인증 관련 API 통신

import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
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

      // 상태 코드 확인 - 401 Unauthorized 또는 다른 오류 상태 코드 확인
      if (response is Response && response.statusCode != 200) {
        if (kDebugMode) {
          print('로그인 실패: 상태 코드 ${response.statusCode}');
          print('오류 메시지: ${response.data}');
        }
        throw Exception('로그인 실패: 인증 오류 (${response.statusCode})');
      }

      // 쿠키 확인 - 로그인 성공 시 쿠키가 있어야 함
      if (response is Response &&
          (response.headers['set-cookie'] == null ||
              response.headers['set-cookie']!.isEmpty)) {
        if (kDebugMode) {
          print('로그인 실패: 인증 쿠키가 없습니다');
        }
        throw Exception('로그인 실패: 인증 쿠키 없음');
      }

      if (kDebugMode) {
        print('로그인 성공, 사용자 정보 조회 시작');
      }

      // 로그인 성공 후 사용자 정보 조회
      try {
        // getUserProfile 메서드를 호출하여 최신 사용자 정보 조회
        final user = await getUserProfile();

        if (kDebugMode) {
          print('로그인 성공 및 사용자 정보 조회 완료: ${user.email}, 이름: ${user.name}');
        }

        return user;
      } catch (profileError) {
        // 사용자 정보 조회 실패 시 기본 정보로 대체
        if (kDebugMode) {
          print('로그인은 성공했으나 사용자 정보 조회 실패: $profileError');
          print('기본 사용자 정보로 대체합니다.');
        }

        // 기본 사용자 객체 생성
        return User(
          id: 0,
          email: email,
          name: email.split('@')[0], // 이메일에서 추출한 기본 이름
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('로그인 요청 오류: $e');
      }
      throw Exception('로그인 실패: $e');
    }
  }

  // 기존 회원가입
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
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('회원가입 프로세스 오류 세부 정보: $e');
      throw Exception('회원가입 실패: $e');
    }
  }

  // 회원가입 완료 API (닉네임과 캐릭터 정보 전송)
  Future<bool> completeSignUp(String userName, String userCharacter) async {
    try {
      final data = {'userName': userName, 'userCharacter': userCharacter};

      if (kDebugMode) {
        print('회원가입 완료 요청 데이터: $data');
        print(
          '회원가입 완료 API 엔드포인트 (상대): ${ApiConstants.signUpCompleteUrl.replaceFirst(ApiConstants.baseUrl, '')}',
        );
        print('회원가입 완료 API 엔드포인트 (전체): ${ApiConstants.signUpCompleteUrl}');
      }

      final response = await _apiService.patch(
        ApiConstants.signUpCompleteUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
      );

      if (kDebugMode) {
        print('회원가입 완료 응답: ${response.data}');
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';

        return statusCode == 'OK';
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('회원가입 완료 요청 오류: $e');
      }
      throw Exception('회원가입 완료 요청 실패: $e');
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
            createdAt: DateTime.now(),
            userCharacter: userData['userCharacter'] ?? '',
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
      // 먼저 저장된 쿠키 확인
      final hasStoredCookies = await _apiService.checkSavedCookies();

      if (kDebugMode) {
        print('저장된 쿠키 확인 결과: $hasStoredCookies');
      }

      // 저장된 쿠키가 있으면 바로 true 반환
      if (hasStoredCookies) {
        return true;
      }

      // 저장된 쿠키가 없으면 서버에 요청하여 확인
      try {
        final response = await _apiService.get(
          ApiConstants.userProfileUrl.replaceFirst(ApiConstants.baseUrl, ''),
        );

        return response is Response && response.statusCode == 200;
      } catch (e) {
        if (kDebugMode) {
          print('서버 쿠키 확인 오류: $e');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('쿠키 확인 오류: $e');
      }
      return false;
    }
  }

  // 비밀번호 재설정 이메일 요청
  Future<bool> requestPasswordReset(String email) async {
    try {
      if (kDebugMode) {
        print('비밀번호 재설정 이메일 요청: $email');
        print(
          '요청 URL: ${ApiConstants.requestPasswordResetUrl}?user-email=$email',
        );
      }

      // 1. 쿼리 파라미터만 사용
      final queryParams = {'user-email': email};

      // 2. 요청 본문은 비워두기
      final data = {};

      if (kDebugMode) {
        print('쿼리 파라미터: $queryParams');
        print('요청 데이터: $data');
      }

      final response = await _apiService.post(
        ApiConstants.requestPasswordResetUrl.replaceFirst(
          ApiConstants.baseUrl,
          '',
        ),
        queryParameters: queryParams,
        data: data,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // 500 에러도 처리하도록 변경
          },
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (kDebugMode) {
        print('비밀번호 재설정 이메일 요청 응답: ${response.data}');
        print('응답 상태 코드: ${response.statusCode}');
        if (response is Response) {
          print('응답 헤더: ${response.headers}');
        }
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';

        // OK가 아니더라도 응답이 왔다면 서버 메시지 확인
        if (statusCode != 'OK') {
          final resMsg =
              responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
          if (kDebugMode) {
            print('비밀번호 재설정 이메일 요청 실패: $resMsg');
          }
          throw Exception(resMsg);
        }

        return statusCode == 'OK';
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재설정 이메일 요청 오류: $e');
      }
      throw Exception('비밀번호 재설정 이메일 요청 실패: $e');
    }
  }

  // 비밀번호 재설정 (토큰 + 새 비밀번호)
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      if (kDebugMode) {
        print('비밀번호 재설정 요청: token=$token');
      }

      final response = await _apiService.post(
        ApiConstants.resetPasswordUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: {'token': token, 'newPassword': newPassword},
        options: Options(
          validateStatus: (status) {
            return status! < 500; // 500 에러도 처리하도록 변경
          },
        ),
      );

      if (kDebugMode) {
        print('비밀번호 재설정 응답: ${response.data}');
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';

        // OK가 아니더라도 응답이 왔다면 서버 메시지 확인
        if (statusCode != 'OK') {
          final resMsg =
              responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
          if (kDebugMode) {
            print('비밀번호 재설정 실패: $resMsg');
          }
          throw Exception(resMsg);
        }

        return statusCode == 'OK';
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('비밀번호 재설정 오류: $e');
      }
      throw Exception('비밀번호 재설정 실패: $e');
    }
  }

  // 회원 탈퇴
  Future<bool> withdrawUser(String password) async {
    try {
      if (kDebugMode) {
        print('회원 탈퇴 요청: password=****');
        print('탈퇴 URL: /users/withdrawal');
      }

      final data = {'password': password};

      final response = await _apiService.delete(
        '/users/withdrawal',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('회원 탈퇴 응답: ${response.data}');
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';
        if (statusCode == 'OK' || response.statusCode == 200) {
          return true;
        } else {
          final resMsg = responseData['resMsg'] as String? ?? '알 수 없는 오류';
          throw Exception(resMsg);
        }
      }
      throw Exception('회원 탈퇴 실패: 서버 응답 오류');
    } catch (e) {
      if (kDebugMode) {
        print('회원 탈퇴 요청 오류: $e');
      }
      throw Exception('회원 탈퇴 실패: $e');
    }
  }

  // 모든 쿠키 삭제
  Future<void> clearCookies() async {
    await _apiService.clearCookies();
  }

  // 이메일 인증 요청
  Future<bool> requestEmailVerification(String email) async {
    try {
      final queryParams = {'user-email': email};
      final response = await _apiService.post(
        '/auth/email/request',
        queryParameters: queryParams,
        data: {},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';
        return statusCode == 'OK';
      }
      return false;
    } catch (e) {
      print('이메일 인증 요청 오류: $e');
      throw Exception('이메일 인증 요청 실패: $e');
    }
  }

  // 이메일 토큰 검증
  Future<bool> verifyEmailToken(String token) async {
    try {
      final queryParams = {'token': token};
      final response = await _apiService.get(
        '/auth/verify-email',
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';
        return statusCode == 'OK';
      }
      return false;
    } catch (e) {
      print('이메일 토큰 검증 오류: $e');
      throw Exception('이메일 토큰 검증 실패: $e');
    }
  }
}
