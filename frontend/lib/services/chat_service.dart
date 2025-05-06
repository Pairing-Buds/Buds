import 'package:dio/dio.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://k12c105.p.ssafy.io/fastapi',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<String> sendMessage({
    required int userId,
    required String message,
    required bool isVoice,
  }) async {
    final response = await _dio.post(
      '/chat/message',
      data: {
        'user_id': userId,
        'message': message,
        'is_voice': isVoice,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['message'];
    } else {
      throw Exception('챗봇 응답 실패');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory({required int userId}) async {
    final response = await _dio.post(
      '/chat/history',
      data: {'user_id': userId},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}
