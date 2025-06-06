// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../constants/api_constants.dart';
import 'api_service.dart';

/// 걸음수 목표 달성 리워드 관련 서비스
class StepRewardService {
  final DioApiService _apiService = DioApiService();

  /// 걸음수 목표 달성 리워드 요청
  Future<Map<String, dynamic>> requestStepReward({
    int? currentSteps,
    int targetSteps = 6000,
  }) async {
    try {
      // 요청 데이터 준비 (목표 걸음수와 실제 걸음수)
      final requestData = {
        "userStepSet": targetSteps, // 목표 걸음수
        "userRealStep": currentSteps ?? targetSteps, // 실제 걸음수 (없으면 목표와 동일하게)
      };

      final response = await _apiService.post(
        ApiConstants.stepRewardUrl,
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response is Response) {
        final responseData = response.data as Map<String, dynamic>? ?? {};
        final statusCode = responseData['statusCode'] as String? ?? '';

        // "OK" 응답인 경우 성공으로 처리
        if (statusCode == "OK") {
          return {
            'success': true,
            'isNewReward': true,
            'message': '걸음수 목표 달성 리워드가 지급되었습니다!',
          };
        }

        // 이미 받은 경우 처리 (서버 응답에 따라 조정 필요)
        if (statusCode == "ALREADY_REWARDED") {
          return {
            'success': true,
            'isNewReward': false,
            'message': '이미 오늘의 걸음수 리워드를 받았습니다.',
          };
        }

        // 다른 에러 상황
        final resMsg =
            responseData['resMsg'] as String? ?? '알 수 없는 오류가 발생했습니다.';
        return {'success': false, 'isNewReward': false, 'message': resMsg};
      }

      return {
        'success': false,
        'isNewReward': false,
        'message': '서버 응답을 처리할 수 없습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'isNewReward': false,
        'message': '걸음수 리워드 요청 실패: $e',
      };
    }
  }

  /// 걸음수 목표 달성 여부 확인
  Future<bool> checkStepGoalAchievement(
    int currentSteps,
    int targetSteps,
  ) async {
    try {
      // 목표 달성 여부 확인
      final isAchieved = currentSteps >= targetSteps;

      return isAchieved;
    } catch (e) {
      return false;
    }
  }
}
