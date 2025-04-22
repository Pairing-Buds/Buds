// API 관련 상수

class ApiConstants {
  // 서버 기본 URL
  static const baseUrl = 'https://api.example.com';

  // 인증 관련 엔드포인트
  static const loginUrl = '$baseUrl/auth/login';
  static const registerUrl = '$baseUrl/auth/register';
  static const logoutUrl = '$baseUrl/auth/logout';

  // 사용자 관련 엔드포인트
  static const userProfileUrl = '$baseUrl/users/profile';

  // 일기 관련 엔드포인트
  static const diariesUrl = '$baseUrl/diaries';
  static const diaryDetailUrl = '$baseUrl/diaries/'; // ID를 뒤에 붙여서 사용

  // 기타 설정
  static const connectionTimeout = 30000; // 밀리초
  static const receiveTimeout = 30000; // 밀리초
}
