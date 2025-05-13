// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../constants/api_constants.dart';
import 'api_service.dart';

class WakeUpService {
  final DioApiService _apiService = DioApiService();

  // 기상 시간 등록
  Future<bool> registerWakeTime(TimeOfDay time) async {
    try {
      // 시간을 "HHmm" 형식으로 변환 (예: "0630", "2359")
      final wakeTime =
          "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}";

      if (kDebugMode) {
        print('기상 시간 등록 요청: $wakeTime');
      }

      final response = await _apiService.post(
        '/activities/wake',
        data: {'wakeTime': wakeTime},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('기상 시간 등록 응답: ${response.data}');
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';

        if (statusCode != 'OK') {
          final resMsg =
              responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
          if (kDebugMode) {
            print('기상 시간 등록 실패: $resMsg');
          }
          throw Exception(resMsg);
        }

        return statusCode == 'OK';
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('기상 시간 등록 오류: $e');
      }
      throw Exception('기상 시간 등록 실패: $e');
    }
  }

  // 기상 시간 검증
  Future<Map<String, dynamic>> verifyWakeUp() async {
    try {
      if (kDebugMode) {
        print('기상 시간 검증 요청');
      }

      final response = await _apiService.post(
        '/activities/wake-verification',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('기상 시간 검증 응답: ${response.data}');
      }

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = response.statusCode;

        // 200: 성공 (리워드 지급)
        // 400: 이미 리워드를 받은 경우 (정상 케이스)
        if (statusCode == 200 || statusCode == 400) {
          return {
            'success': true,
            'isNewReward': statusCode == 200,
            'message':
                statusCode == 200 ? '오늘의 리워드가 지급되었습니다!' : '이미 오늘의 리워드를 받았습니다.',
          };
        }

        // 다른 에러 상황
        final resMsg =
            responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
        if (kDebugMode) {
          print('기상 시간 검증 실패: $resMsg');
        }
        return {'success': false, 'isNewReward': false, 'message': resMsg};
      }

      return {
        'success': false,
        'isNewReward': false,
        'message': '서버 응답을 처리할 수 없습니다.',
      };
    } catch (e) {
      if (kDebugMode) {
        print('기상 시간 검증 오류: $e');
      }
      return {
        'success': false,
        'isNewReward': false,
        'message': '기상 시간 검증 실패: $e',
      };
    }
  }
}
