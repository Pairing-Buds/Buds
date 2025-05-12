// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'package:buds/models/activity_quote_model.dart';
import 'package:buds/models/activity_user_model.dart';
import 'package:buds/services/api_service.dart';

class ActivityService {
  final DioApiService _apiService = DioApiService();
  // 1. STT
  // 명언 API 조회
  Future<ActivityQuoteModel> fetchDailyQuote() async {
    final quoteSearchUrl = '${ApiConstants.baseUrl}/activities/quote';

    try {
      final response = await _apiService.get(quoteSearchUrl);

      if (response.statusCode == 200) {
        return ActivityQuoteModel.fromJson(response.data);
      } else {
        throw Exception('명언 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('명언 조회 오류: $e');
    }
  }

  // STT 결과 전송
  Future<bool> submitSttResult({
    required String originalSentenceText,
    required String userSentenceText,
  }) async {
    try {
      final requestData = {
        "originalSentenceText": originalSentenceText,
        "userSentenceText": userSentenceText,
      };

      print("STT 전송 데이터: $requestData");

      final response = await _apiService.post(
        ApiConstants.voiceSendUrl,
        data: jsonEncode(requestData), // JSON 형식으로 전송
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print("STT 제출 성공: ${response.data}");
        return true;
      } else {
        print("STT 제출 실패: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      print("STT 제출 에러: $e");
      return false;
    }
  }

  // 2. 알라딘 API 조회
  Future<Map<String, String>> fetchMentalHealthBook() async {
    final bookUrl = dotenv.env['BOOK_URL'];
    final ttbKey = dotenv.env['TTBKEY'];

    _validateEnvVariables(bookUrl, ttbKey);

    final url = Uri.parse('$bookUrl?ttbkey=$ttbKey&QueryType=ItemNewSpecial&MaxResults=1&Start=1&SearchTarget=Book&CategoryId=51378&Output=JS&Version=20131101');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseBookData(data);
    } else {
      throw Exception('도서 조회 실패: ${response.statusCode}');
    }
  }

  void _validateEnvVariables(String? bookUrl, String? ttbKey) {
    if (bookUrl == null || bookUrl.isEmpty || ttbKey == null || ttbKey.isEmpty) {
      throw Exception('환경 변수 설정 오류: BOOK_URL 또는 ttbKey가 설정되지 않았습니다.');
    }
  }

  Map<String, String> _parseBookData(Map<String, dynamic> data) {
    final items = data['item'];

    if (items == null || items.isEmpty) {
      throw Exception('책 정보 없음 (item 배열이 비어 있음)');
    }

    final item = items[0];

    return {
      'title': item['title'] ?? '알 수 없음',
      'author': item['author'] ?? '알 수 없음',
      'cover': item['cover'] ?? '',
    };
  }

  // 3. 태그 기반 추천 유저
  Future<List<ActivityUserModel>> fetchActivityUser() async {
    try {
      final response = await _apiService.get(ApiConstants.userRecommendUrl);
      if (response.statusCode == 200) {
        final List<dynamic> userList = response.data['resMsg'];
        return userList
            .map((user) => ActivityUserModel.fromJson(user))
            .toList();
      } else {
        throw Exception('추천 사용자 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('추천 사용자 조회 오류: $e');
    }
  }


  //4. 걸음수 목표 달성 리워드 요청
  Future<Map<String, dynamic>> requestStepReward() async {
    try {
      print("걸음수 목표 달성 리워드 요청");
      
      final response = await _apiService.post(
        ApiConstants.stepRewardUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('걸음수 리워드 응답: ${response.data}');
      
      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = response.statusCode;
        
        // 200: 성공 (리워드 지급)
        // 400: 이미 리워드를 받은 경우 (정상 케이스)
        if (statusCode == 200 || statusCode == 400) {
          return {
            'success': true,
            'isNewReward': statusCode == 200,
            'message': statusCode == 200 
                ? '걸음수 목표 달성 리워드가 지급되었습니다!' 
                : '이미 오늘의 걸음수 리워드를 받았습니다.',
          };
        }
        
        // 다른 에러 상황
        final resMsg = responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
        print('걸음수 리워드 요청 실패: $resMsg');
        return {'success': false, 'isNewReward': false, 'message': resMsg};
      }
      
      return {
        'success': false,
        'isNewReward': false,
        'message': '서버 응답을 처리할 수 없습니다.',
      };
    } catch (e) {
      print('걸음수 리워드 요청 오류: $e');
      return {
        'success': false,
        'isNewReward': false,
        'message': '걸음수 리워드 요청 실패: $e',
      };
    }
  }
}
