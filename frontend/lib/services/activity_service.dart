import 'api_service.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
// import`1 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:buds/models/activity_model.dart';

class ActivityService {
  final DioApiService _apiService = DioApiService();

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
        print("📤 STT 제출 성공: ${response.data}");
        return true;
      } else {
        print("❌ STT 제출 실패: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ STT 제출 에러: $e");
      return false;
    }
  }

  // 알라딘 API 조회
  Future<Map<String, String>> fetchMentalHealthBook() async {
    final bookUrl = dotenv.env['BOOK_URL'];
    final ttbKey = dotenv.env['ttbKey'];

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
}
