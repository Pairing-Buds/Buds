// API 관련 상수

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static String get fastApiUrl {
    final fastUrl = dotenv.env['FASTAPI_URL'];
    if (fastUrl == null || fastUrl.isEmpty) {
      if (kDebugMode) {
        print('경고: FASTAPI_URL 환경 변수가 설정되지 않았습니다.');
      }
      return '';
    }
    return fastUrl;
  }

  // 인증 관련 엔드포인트
  static String get loginUrl => '$baseUrl/login';
  static String get registerUrl => '$baseUrl/auth/sign-up';
  static String get signUpCompleteUrl => '$baseUrl/auth/sign-up/complete';
  static String get logoutUrl => '$baseUrl/logout';

  // 비밀번호 재설정 관련 엔드포인트
  static String get requestPasswordResetUrl =>
      '$baseUrl/auth/email/request/password-reset';
  static String get resetPasswordUrl => '$baseUrl/auth/reset-password';

  // 사용자 관련 엔드포인트
  static String get userProfileUrl => '$baseUrl/users/my-info';
  static String get randomNicknameUrl => '$baseUrl/auth/random-nickname';
  static String get tagUrl => '$baseUrl/users/all-tags'; // 전체 태그 조회

  // 일기 관련 엔드포인트
  static String get diariesUrl => '$baseUrl/diaries';
  static String get diaryDetailUrl => '$baseUrl/diaries/'; // ID를 뒤에 붙여서 사용

  // 편지 관련 엔드포인트
  static String get letterListUrl => '$baseUrl/letters/chats'; // 편지 목록 조회
  static String get letterDetailUrl =>
      '$baseUrl/letters/chats/details'; // 랜덤 편지(특정 사용자와 주고 받은 편지)
  static String get letterSingleUrl => '$baseUrl/letters/detail'; // 편지 상세 조회
  static String get letterAnonymityUrl => '$baseUrl/letters/send'; // 편지 발송
  static String get letterLatestUrl =>
      '$baseUrl/letters/latest-received'; // 최근 수신 편지
  static String get letterAnswerUrl => '$baseUrl/letters/answer'; // 편지 id로 답장

  // 캘린더 관련 엔드포인트
  static String get calendarDiaryUrl => '$baseUrl/calendars/'; // 뒤에 yyyy-MM 붙이기

  // 설문조사 관련 엔드포인트
  static String get surveyUrl => '$baseUrl/users/survey-result'; // 설문조사 제출
  static String get userTagUrl => '$baseUrl/users/tags'; // 유저 태그 조회

  // 활동관련 엔드포인트
  // 1. 활동 - STT
  static String get quoteSearchUrl => '$baseUrl/activities/quote'; // 명언 랜덤 조회
  static String get voiceSendUrl =>
      '$baseUrl/activities/sentence-voice'; // 문장 음성 텍스트 입력
  static String get stepRewardUrl =>
      '$baseUrl/activities/walk'; // 걸음수 목표 달성 리워드

  // 2. 활동 - 추천 친구
  static String get userRecUrl =>
      '$baseUrl/activities/find-friend-by-tag'; // 추천 친구 url
  static String get userIdLetterSendUrl =>
      '$baseUrl/letters/to-specific-user'; // 유저 id로 편지 보내기

  // 기타 설정
  static const connectionTimeout = 30000; // 밀리초
  static const receiveTimeout = 30000; // 밀리초

  //채팅
  static String get chatMessageUrl => '$fastApiUrl/chat/message';
  static String get chatHistoryUrl => '$fastApiUrl/chat/history';
  static String get generateDiaryUrl => '$fastApiUrl/diary/generate';

  // 문의 관련 엔드포인트
  static String get inquiryListUrl => '$baseUrl/cs';
  static String get inquiryCreateUrl => '$baseUrl/cs';
}
