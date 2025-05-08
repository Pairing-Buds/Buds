import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:buds/models/letter_model.dart';
import '../constants/api_constants.dart';
import 'dio_api_service.dart';

class LetterService {
  final DioApiService _apiService = DioApiService();

  /// 편지 목록 조회
  Future<List<LetterModel>> fetchLetters() async {
    try {
      final response = await _apiService.get(
        ApiConstants.letterListUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['statusCode'] == 'OK' && data['resMsg'] != null) {
          final chatList = data['resMsg']['chatList'] as List<dynamic>;
          return chatList.map((json) => LetterModel.fromJson(json)).toList();
        } else {
          throw Exception('응답 형식 오류');
        }
      } else {
        throw Exception('편지 목록 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('fetchLetters 오류: $e');
      }
      rethrow;
    }
  }

  /// 편지 스크랩 토글
  Future<bool> toggleScrap(int letterId) async {
    try {
      final response = await _apiService.post(
        '/letters/scrap',
        data: {'letterId': letterId},
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('toggleScrap 오류: $e');
      }
      return false;
    }
  }
}
