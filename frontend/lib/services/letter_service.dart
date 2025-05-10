import 'api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:buds/models/letter_model.dart';
import 'package:buds/models/letter_response_model.dart';

class LetterService {
  final DioApiService _apiService = DioApiService();

  /// 편지 목록 조회
  Future<LetterResponseModel> fetchLetters() async {
    try {
      final response = await _apiService.get(
        ApiConstants.letterListUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['statusCode'] == 'OK' && data['resMsg'] != null) {
          return LetterResponseModel.fromJson(data);
        } else {
          throw Exception('응답 형식 오류');
        }
      } else {
        throw Exception('편지 목록 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('fetchLetters 오류: $e');
      }
      rethrow;
    }
  }

  /// 특정 사용자와 주고 받은 편지
  Future<List<LetterModel>> fetchLetterDetails({
    required int opponentId,
    required int page,
    required int size,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.letterDetailUrl.replaceFirst(ApiConstants.baseUrl, ''),
        queryParameters: {
          'opponentId': opponentId,
          'page': page,
          'size': size,
        },
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['statusCode'] == 'OK' && data['resMsg'] != null) {
          final chatList = data['resMsg']['chatList'] as List<dynamic>;
          return chatList.map((json) => LetterModel.fromJson(json)).toList();
        } else {
          throw Exception('응답 형식 오류');
        }
      } else {
        throw Exception('편지 상세 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('fetchLetterDetails 오류: $e');
      }
      rethrow;
    }
  }

  /// 편지 디테일 조회
  Future<LetterModel> fetchSingleLetter(int letterId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.letterSingleUrl.replaceFirst(ApiConstants.baseUrl, ''),
        queryParameters: {'letterId': letterId},
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['statusCode'] == 'OK' && data['resMsg'] != null) {
          return LetterModel.fromJson(data['resMsg']);
        } else {
          throw Exception('응답 형식 오류');
        }
      } else {
        throw Exception('싱글 편지 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('fetchSingleLetter 오류: $e');
      }
      rethrow;
    }
  }

  /// 편지 스크랩 토글
  Future<bool> toggleScrap(int letterId) async {
    try {
      final response = await _apiService.post(
        '/letters/scrap',
        data: {'letterId': letterId},
      );

      if (response is Response && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('toggleScrap 오류: $e');
      }
      return false;
    }
  }
}
