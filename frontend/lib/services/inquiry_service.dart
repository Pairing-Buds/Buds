// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../constants/api_constants.dart';
import '../models/inquiry.dart';
import 'api_service.dart';

class DioInquiryService {
  final DioApiService _apiService = DioApiService();

  // 문의 내역 조회
  Future<InquiryResponse?> fetchInquiries() async {
    try {
      // ApiConstants에서 엔드포인트 사용
      final response = await _apiService.get(
        ApiConstants.inquiryListUrl.replaceFirst(ApiConstants.baseUrl, ''),
      );

      if (kDebugMode) {
        print('문의 조회 응답: \\${response.data}');
      }

      if (response is Response && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['statusCode'] == 'OK') {
          return InquiryResponse.fromJson(data);
        } else {
          if (kDebugMode) {
            print('문의 조회 실패: \\${data['resMsg']}');
          }
          return null;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('문의 조회 오류: \\${e}');
      }
      return null;
    }
  }

  // 문의 생성
  Future<bool> createInquiry(String subject, String content) async {
    try {
      final response = await _apiService.post(
        ApiConstants.inquiryCreateUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: {
          'subject': subject,
          'content': content,
        },
      );

      if (kDebugMode) {
        print('문의 생성 응답: ${response.data}');
      }

      if (response is Response && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('문의 생성 오류: $e');
      }
      return false;
    }
  }

  // 문의 수정 
  Future<bool> updateInquiry(int questionId, String subject, String content) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.inquiryCreateUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: {
          'questionId': questionId,
          'subject': subject,
          'content': content,
        },
      );

      if (kDebugMode) {
        print('문의 수정 응답: ${response.data}');
      }

      if (response is Response && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('문의 수정 오류: $e');
      }
      return false;
    }
  }

  // 문의 삭제
  Future<bool> deleteInquiry(int questionId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.inquiryCreateUrl.replaceFirst(ApiConstants.baseUrl, ''),
        data: {
          'questionId': questionId,
        },
      );

      if (kDebugMode) {
        print('문의 삭제 응답: ${response.data}');
      }

      if (response is Response && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['statusCode'] == 'OK';
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('문의 삭제 오류: $e');
      }
      return false;
    }
  }
}
