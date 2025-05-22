import 'package:dio/dio.dart';
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

      if (e.response?.statusCode == 422 || e.response?.statusCode == 500) {
        final fallbackMsg = resData is Map && resData['response'] is String
            ? resData['response']
            : '음성 인식에 실패했어요. 다시 시도해 주세요.';
        return fallbackMsg;
      }

      return '대화 중 오류가 발생했어요.';
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final response = await _fastApiService.post(
        '/chat/history',
        data: {'limit': 50},
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
