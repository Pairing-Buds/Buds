import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'dio_api_service.dart';

class SurveyService {
  final DioApiService _apiService = DioApiService();

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
}