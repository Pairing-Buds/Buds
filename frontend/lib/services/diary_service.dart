// 일기 관련 API 서비스

import '../constants/api_constants.dart';
import '../models/diary_model.dart';
import 'dio_api_service.dart';

class DiaryService {
  final DioApiService _apiService = DioApiService();

  // 일기 목록 조회
  Future<List<Diary>> getDiaries({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.diariesUrl.replaceFirst(ApiConstants.baseUrl, ''),
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> diaryList = response['data'];
      return diaryList.map((json) => Diary.fromJson(json)).toList();
    } catch (e) {
      throw Exception('일기 목록 조회 실패: $e');
    }
  }

  // 일기 상세 조회
  Future<Diary> getDiaryDetail(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.diaryDetailUrl.replaceFirst(ApiConstants.baseUrl, '')}$id',
      );

      return Diary.fromJson(response['data']);
    } catch (e) {
      throw Exception('일기 상세 조회 실패: $e');
    }
  }

  // 일기 작성
  Future<Diary> createDiary(String title, String content, String mood) async {
    try {
      final data = {'title': title, 'content': content, 'mood': mood};

      final response = await _apiService.post(
        ApiConstants.diariesUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: data,
      );

      return Diary.fromJson(response['data']);
    } catch (e) {
      throw Exception('일기 작성 실패: $e');
    }
  }

  // 일기 수정
  Future<Diary> updateDiary(
    String id, {
    String? title,
    String? content,
    String? mood,
  }) async {
    try {
      final data = {};

      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (mood != null) data['mood'] = mood;

      final response = await _apiService.put(
        '${ApiConstants.diaryDetailUrl.replaceFirst(ApiConstants.baseUrl, '')}$id',
        data: data,
      );

      return Diary.fromJson(response['data']);
    } catch (e) {
      throw Exception('일기 수정 실패: $e');
    }
  }

  // 일기 삭제
  Future<void> deleteDiary(String id) async {
    try {
      await _apiService.delete(
        '${ApiConstants.diaryDetailUrl.replaceFirst(ApiConstants.baseUrl, '')}$id',
      );
    } catch (e) {
      throw Exception('일기 삭제 실패: $e');
    }
  }
}
