// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'api_service.dart';

class SurveyService {
  final DioApiService _apiService = DioApiService();

  /// 관심 태그 조회
  Future<List<String>> fetchSurveyTags() async {
    try {
      final response = await _apiService.get(ApiConstants.tagUrl);
      if (response is Response && response.statusCode == 200) {
        final data = response.data;
        if (data['statusCode'] == "OK") {
          return List<String>.from(data['resMsg']);
        }
      }
      return [];
    } catch (e) {
      print("Error fetching survey tags: $e");
      return [];
    }
  }

  /// 설문조사 결과 보내기
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
}
