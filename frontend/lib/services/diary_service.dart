import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/diary_model.dart';
import 'api_service.dart';

class DiaryService {
  final DioApiService _apiService = DioApiService();

  Future<List<DiaryDay>> getDiaryByMonth(String date) async {
    try {
      final response = await _apiService.get('/calendars/day/$date');
      final data = response.data;

      if (data['statusCode'] != 'OK') {
        throw Exception('일기 데이터 조회 실패');
      }

      final List<dynamic> resMsg = data['resMsg'];
      return resMsg.map((e) => DiaryDay.fromJson(e)).toList();
    } catch (e) {
      throw Exception('일기 API 오류: $e');
    }
  }

  Future<Map<String, String>> generateDiary(int userId) async {
    try {
      final dio = Dio(); // 별도 FastAPI 호출이므로 직접 사용
      final response = await dio.post(
        'http://k12c105.p.ssafy.io/fastapi/diary/generate',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'emotion_diary': response.data['emotion_diary'],
          'active_diary': response.data['active_diary'],
        };
      } else {
        throw Exception('일기 생성 실패');
      }
    } catch (e) {
      throw Exception('일기 생성 오류: $e');
    }
  }

  Future<bool> createDiary({
    required String emotionDiary,
    required String activeDiary,
    required String date,
  }) async {
    try {
      final response = await _apiService.post(
        '/diaries',
        data: {
          'emotion_diary': emotionDiary,
          'active_diary': activeDiary,
          'date': date,
        },
      );

      return response.data['statusCode'] == 'OK' &&
          response.data['resMsg'] == 'CREATED';
    } catch (e) {
      throw Exception('일기 저장 실패: $e');
    }
  }


}
