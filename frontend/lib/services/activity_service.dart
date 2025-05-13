// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'package:buds/models/activity_quote_model.dart';
import 'package:buds/models/tag_rec_user_model.dart';
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
        options: Options(headers: {'Content-Type': 'application/json'}),
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

    final url = Uri.parse(
      '$bookUrl?ttbkey=$ttbKey&QueryType=Bestseller&MaxResults=1&Start=1&SearchTarget=Book&CategoryId=51378&Output=JS&Version=20131101',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseBookData(data);
    } else {
      throw Exception('도서 조회 실패: ${response.statusCode}');
    }
  }

  void _validateEnvVariables(String? bookUrl, String? ttbKey) {
    if (bookUrl == null ||
        bookUrl.isEmpty ||
        ttbKey == null ||
        ttbKey.isEmpty) {
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
  // 유저 및 태그 조회
  Future<List<TagRecUserModel>> fetchRecUser() async {
    try {
      final response = await _apiService.get(ApiConstants.userRecUrl);
      if (response.statusCode == 200) {
        final List<dynamic> userList = response.data['resMsg'];
        return userList.map((user) {
          final tagRecUser = TagRecUserModel.fromJson(user);

          if (tagRecUser.tagTypes.isEmpty) {
            throw Exception('추천 사용자 조회 실패: 태그가 최소 1개 필요합니다.');
          }
          return tagRecUser;
        }).toList();
      } else {
        throw Exception('추천 사용자 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('추천 사용자 조회 오류: $e');
    }
  }

  // 조회된 유저에게 편지 전송
  Future<bool> sendUserLetter(int receiverId, String content) async {
    try {
      final response = await _apiService.post(
        ApiConstants.userIdLetterSendUrl,
        data: {'receiverId': receiverId, 'content': content},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      } else {
        throw Exception('편지 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('편지 전송 오류: $e');
    }
  }
}
