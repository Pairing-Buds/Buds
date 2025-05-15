// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/fast_api_service.dart';

class ChatService {
  final FastApiService _fastApiService = FastApiService();

  Future<String> sendMessage({
    required String message,
    required bool isVoice,
  }) async {
    try {
      final response = await _fastApiService.post(
        '/chat/message',
        data: {
          'message': message,
          'is_voice': isVoice,
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return data['message'] ?? '응답 없음';
      } else {
        throw Exception('서버 응답 형식 오류: $data');
      }
    } on DioException catch (e) {
      final resData = e.response?.data;

      // ✅ 임시 방편: message 필드가 없을 경우 기본 응답 제공
      if (e.response?.statusCode == 422 || e.response?.statusCode == 500) {
        final fallbackMsg = resData is Map && resData['response'] is String
            ? resData['response']
            : '음성 인식에 실패했어요. 다시 시도해 주세요.';
        return fallbackMsg;
      }

      return '대화 중 오류가 발생했어요.';
    }
  }

  Future<Map<String, dynamic>> getChatHistory(
      {int offset = 0, int limit = 30}) async {
    try {
      final response = await _fastApiService.post(
        '/chat/history',
        data: {'offset': offset, 'limit': limit},
      );

      final data = response.data;
      return {
        'messages': List<Map<String, dynamic>>.from(data['messages']),
        'hasMore': data['has_more'],
        'nextOffset': data['next_offset'],
        'totalCount': data['total_count'],
      };
    } catch (e) {
      print('❌ getChatHistory 오류: $e');
      return {
        'messages': [],
        'hasMore': false,
        'nextOffset': null,
        'totalCount': 0,
      };
    }
  }
}