// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:buds/services/fast_api_service.dart';

class ChatService {
  final FastApiService _fastApiService = FastApiService();

  Future<Map<String, dynamic>> sendMessage({
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
        // 텍스트와 오디오 경로를 항상 map으로 반환
        return {
          'text': data['text'] ?? data['message'] ?? '응답 없음',
          'audioPath': data['audio_path'] ?? null,
        };
      } else {
        throw Exception('서버 응답 형식 오류: $data');
      }
    } on DioException catch (e) {
      print('❌ 메시지 전송 실패: $e');
      return {
        'text': '친구 집에 놀러왔어. 이따가 연락할게.',
        'audioPath': null,
      };
    }
  }


  Future<Map<String, dynamic>> getChatHistory(
      {int offset = 0, int limit = 100}) async {
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