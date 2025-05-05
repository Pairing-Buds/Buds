// API 관련 상수
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // 서버 기본 URL - .env 파일에서 로드
  static String get baseUrl {
    final envUrl = dotenv.env['API_URL'];

    if (envUrl == null || envUrl.isEmpty) {
      // 환경 변수가 없는 경우, 개발 모드에서만 경고 출력
      if (kDebugMode) {
        print('경고: API_URL 환경 변수가 설정되지 않았습니다.');
      }
      return '';
    }

    return envUrl;
  }

  // 인증 관련 엔드포인트
  static String get loginUrl => '$baseUrl/login';
  static String get registerUrl => '$baseUrl/auth/sign-up';
  static String get logoutUrl => '$baseUrl/auth/logout';

  // 사용자 관련 엔드포인트
  static String get userProfileUrl => '$baseUrl/users/my-info';

  // 일기 관련 엔드포인트
  static String get diariesUrl => '$baseUrl/diaries';
  static String get diaryDetailUrl => '$baseUrl/diaries/'; // ID를 뒤에 붙여서 사용

  // 기타 설정
  static const connectionTimeout = 30000; // 밀리초
  static const receiveTimeout = 30000; // 밀리초
}
