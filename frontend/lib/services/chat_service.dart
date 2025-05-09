import 'package:dio/dio.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://k12c105.p.ssafy.io/fastapi',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<String> sendMessage({
    required int userId,
    required String message,
    required bool isVoice,
  }) async {
    try {
      print("✅ ChatService 요청 시작");
      print("user_id: $userId");
      print("message: $message");
      print("is_voice: $isVoice");

      final response = await _dio.post(
        '/chat/message',
        data: {
          'user_id': userId,
          'message': message,
          'is_voice': isVoice,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ 응답 상태 코드: ${response.statusCode}');
      print('✅ 응답 데이터: ${response.data}');

      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['success'] == true) {
        return data['message'] ?? '응답 없음';
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}, data: $data');
      }
    } catch (e, stack) {
      print('❌ sendMessage 오류: $e');
      print(stack);
      return '친구 집에 놀러갔어. 나중에 대화하자!';
    }
  }


  Future<List<Map<String, dynamic>>> getChatHistory({required int userId}) async {
    final response = await _dio.post(
      '/chat/history',
      data: {'user_id': userId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      return []; // 잘못된 응답이면 빈 리스트로 처리
    }
  }
}
