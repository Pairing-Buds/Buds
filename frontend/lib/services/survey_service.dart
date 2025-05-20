// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'api_service.dart';

class SurveyService {
  final DioApiService _apiService = DioApiService();

  /// 1. 최초 설문조사 결과 보내기
  Future<bool> submitSurveyResult({
    required int seclusionScore,
    required int opennessScore,
    required int sociabilityScore,
    required int routineScore,
    required int quietnessScore,
    required int expressionScore,
    required List<String> tags,
  }) async {
    try {
      final requestData = {
        "seclusionScore": seclusionScore,
        "opennessScore": opennessScore,
        "sociabilityScore": sociabilityScore,
        "routineScore": routineScore,
        "quietnessScore": quietnessScore,
        "expressionScore": expressionScore,
        "tags": tags.map((tag) => tag.toUpperCase()).toList(),
      };
      print("설문조사 Request 데이터: $requestData");

      final response = await _apiService.post(
        ApiConstants.surveyUrl,
        data: {
          "seclusionScore": seclusionScore,
          "opennessScore": opennessScore,
          "sociabilityScore": sociabilityScore,
          "routineScore": routineScore,
          "quietnessScore": quietnessScore,
          "expressionScore": expressionScore,
          "tags": tags.map((tag) => tag.toUpperCase()).toList(),
        },
      );
      if (response is Response && response.statusCode == 200) {
        print("설문조사 제출 성공");
        return true;
      }
      print("설문조사 제출 실패: ${response.statusCode}");
      return false;
    } catch (e) {
      print("설문조사 제출 에러: $e");
      return false;
    }
  }

  /// 2. 재태그 결과 제출
  Future<bool> submitRetagResult({required List<String> tags}) async {
    try {
      final requestData = {"tagTypes": tags};

      final response = await _apiService.post(
        ApiConstants.submitRetagUrl,
        data: requestData,
      );
      if (response is Response && response.statusCode == 200) {
        print("태그업데이트 성공");
        return true;
      }
      print("태그업데이트 실패: ${response.statusCode}");
      return false;
    } catch (e) {
      print("태그업데이트 에러: $e");
      return false;
    }
  }

  /// 3. 재설문 제출
  Future<bool> resurveySubmit({
    required int seclusionScore,
    required int opennessScore,
    required int sociabilityScore,
    required int routineScore,
    required int quietnessScore,
    required int expressionScore,
  }) async {
    try {
      final requestData = {
        "seclusionScore": seclusionScore,
        "opennessScore": opennessScore,
        "sociabilityScore": sociabilityScore,
        "routineScore": routineScore,
        "quietnessScore": quietnessScore,
        "expressionScore": expressionScore,
      };

      final response = await _apiService.post(
        ApiConstants.resurveyUrl,
        data: requestData,
      );

      if (response.statusCode == 200) {
        print("재설문조사 제출 성공");
        return true;
      }
      print("재설문조사 제출 실패: ${response.statusCode}");
      return false;
    } catch (e) {
      print("재설문조사 제출 에러: $e");
      return false;
    }
  }
}
