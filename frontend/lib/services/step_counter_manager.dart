// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'notification_service.dart';
import 'step_reward_service.dart';

class StepCounterManager {
  // 싱글톤 패턴 구현
  static final StepCounterManager _instance = StepCounterManager._internal();
  factory StepCounterManager() => _instance;
  StepCounterManager._internal() {
    // 싱글톤 생성자에서 자동으로 초기화 호출
    initialize();
  }

  // 플랫폼 채널 설정
  static const MethodChannel _methodChannel = MethodChannel(
    'com.budsapp/stepcounter',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.budsapp/stepcounter_events',
  );

  // 걸음 수 관련 변수
  int _currentSteps = 0;
  int _targetSteps = 6000; // 기본 목표 걸음 수
  bool _isServiceRunning = false;
  bool _isEventListenerSet = false;
  bool _isInitialized = false; // 초기화 여부 확인
  bool _isRewardRequested = false; // 오늘 리워드를 이미 요청했는지 여부

  // 걸음 수 스트림 컨트롤러
  final _stepCountController = StreamController<int>.broadcast();
  Stream<int> get stepCountStream => _stepCountController.stream;

  // 서비스 상태 스트림 컨트롤러
  final _serviceStatusController = StreamController<bool>.broadcast();
  Stream<bool> get serviceStatusStream => _serviceStatusController.stream;

  // 리워드 상태 스트림 컨트롤러
  final _rewardStatusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get rewardStatusStream => _rewardStatusController.stream;

  // 리워드 서비스
  final StepRewardService _stepRewardService = StepRewardService();

  // 걸음 수 getter
  int get currentSteps => _currentSteps;
  int get targetSteps => _targetSteps;
  bool get isServiceRunning => _isServiceRunning;
  bool get isRewardRequested => _isRewardRequested;
  double get stepAchievementRate =>
      _targetSteps > 0 ? _currentSteps / _targetSteps : 0;

  // 초기화
  Future<void> initialize() async {
    // 이미 초기화 완료된 경우 중복 실행 방지
    if (_isInitialized) {
      debugPrint('StepCounterManager: 이미 초기화되었습니다.');
      return;
    }

    debugPrint('StepCounterManager: 초기화 시작...');

    try {
      // 이전에 저장된 걸음 수 로드
      await _loadSavedSteps();
      
      // 이전에 저장된 리워드 요청 상태 로드
      await _loadRewardRequestStatus();

      // 권한 확인
      final hasPermission = await checkPermission();
      debugPrint('StepCounterManager: 권한 확인 결과 - $hasPermission');

      if (hasPermission) {
        // 걸음 수 이벤트 리스너 설정
        _setupStepCountListener();

        // 현재 걸음 수 가져오기
        await getCurrentSteps();

        // 서비스 상태 확인
        await _checkServiceStatus();

        // 초기화 완료 표시
        _isInitialized = true;
        debugPrint('StepCounterManager: 초기화 완료');
      } else {
        debugPrint('StepCounterManager: 권한이 없어 초기화를 완료할 수 없습니다.');
        // 권한 요청 부분 주석 처리 - 초기화 시 자동으로 권한 요청하지 않음
        // 대신 사용자가 실제로 걸음 수 기능을 사용할 때만 권한 요청
        // final granted = await requestPermission();
        // if (granted) {
        //   // 권한이 승인된 경우 초기화 재시도
        //   await initialize();
        // }
      }
    } catch (e) {
      debugPrint('StepCounterManager: 초기화 중 오류 발생 - $e');
      // 5초 후에 다시 초기화 시도
      Future.delayed(const Duration(seconds: 5), () {
        initialize();
      });
    }
  }

  // 저장된 걸음 수 불러오기
  Future<void> _loadSavedSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSteps = prefs.getInt('user_current_steps');
      final savedTarget = prefs.getInt('user_target_steps');

      if (savedSteps != null) {
        _currentSteps = savedSteps;
        _stepCountController.add(_currentSteps);
        debugPrint('저장된 걸음 수 로드됨: $_currentSteps');
      }

      if (savedTarget != null) {
        _targetSteps = savedTarget;
        debugPrint('저장된 목표 걸음 수 로드됨: $_targetSteps');
      }
    } catch (e) {
      debugPrint('저장된 걸음 수 로드 오류: $e');
    }
  }

  // 저장된 리워드 요청 상태 불러오기
  Future<void> _loadRewardRequestStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRewardDate = prefs.getString('last_step_reward_date');
      
      if (lastRewardDate != null) {
        final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD 형식
        _isRewardRequested = lastRewardDate == today;
        debugPrint('저장된 리워드 요청 상태 로드됨: $_isRewardRequested (마지막 요청일: $lastRewardDate)');
      } else {
        _isRewardRequested = false;
      }
    } catch (e) {
      debugPrint('저장된 리워드 요청 상태 로드 오류: $e');
      _isRewardRequested = false;
    }
  }

  // 리워드 요청 상태 저장
  Future<void> _saveRewardRequestStatus(bool requested) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD 형식
      
      if (requested) {
        await prefs.setString('last_step_reward_date', today);
      }
      
      _isRewardRequested = requested;
      debugPrint('리워드 요청 상태 저장됨: $_isRewardRequested (날짜: $today)');
    } catch (e) {
      debugPrint('리워드 요청 상태 저장 오류: $e');
    }
  }

  // 서비스 상태 확인
  Future<void> _checkServiceStatus() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'isServiceRunning',
      );
      _isServiceRunning = result ?? false;
      _serviceStatusController.add(_isServiceRunning);
      debugPrint('서비스 실행 상태: $_isServiceRunning');
    } catch (e) {
      debugPrint('서비스 상태 확인 오류: $e');
      _isServiceRunning = false;
      _serviceStatusController.add(_isServiceRunning);
    }
  }

  // 걸음 수 이벤트 리스너 설정
  void _setupStepCountListener() {
    if (_isEventListenerSet) return;

    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is int) {
          _currentSteps = event;
          _stepCountController.add(event);
          debugPrint('걸음 수 이벤트 수신: $_currentSteps');
          
          // 목표 달성 확인 및 리워드 요청
          _checkGoalAchievement();
        }
      },
      onError: (error) {
        debugPrint('Step counter error: $error');
      },
    );

    _isEventListenerSet = true;
    debugPrint('걸음 수 이벤트 리스너 설정됨');
  }

  // 목표 달성 확인 및 리워드 요청
  Future<void> _checkGoalAchievement() async {
    // 목표를 달성했고, 오늘 아직 리워드를 요청하지 않았다면
    if (_currentSteps >= _targetSteps && !_isRewardRequested) {
      debugPrint('목표 걸음 수 $_targetSteps 달성! 현재: $_currentSteps');
      await requestStepReward();
    }
  }

  // 걸음수 목표 달성 리워드 요청
  Future<Map<String, dynamic>> requestStepReward() async {
    // 이미 오늘 리워드를 요청했다면 중복 요청 방지
    if (_isRewardRequested) {
      final result = {
        'success': true,
        'isNewReward': false,
        'message': '이미 오늘의 걸음수 리워드를 받았습니다.',
      };
      _rewardStatusController.add(result);
      return result;
    }

    try {
      debugPrint('걸음수 목표 달성 리워드 요청 시작');
      final result = await _stepRewardService.requestStepReward(
        currentSteps: _currentSteps,
        targetSteps: _targetSteps
      );
      
      // 요청 성공 시 상태 저장
      if (result['success'] == true) {
        await _saveRewardRequestStatus(true);
      }
      
      // 결과 스트림에 전송
      _rewardStatusController.add(result);
      
      return result;
    } catch (e) {
      debugPrint('걸음수 리워드 요청 오류: $e');
      final result = {
        'success': false,
        'isNewReward': false,
        'message': '걸음수 리워드 요청 실패: $e',
      };
      _rewardStatusController.add(result);
      return result;
    }
  }

  // 권한 확인 (활동 인식 권한만 확인)
  Future<bool> checkPermission() async {
    try {
      // Android 10 이상에서는 ACTIVITY_RECOGNITION 권한 필요
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  // 권한 요청 - 활동 인식 및 알림 권한 함께 요청
  // 반환값: 'activity' - 활동 인식 권한 상태, 'notification' - 알림 권한 상태
  Future<Map<String, bool>> requestPermissions() async {
    try {
      // 활동 인식 권한 요청 (걸음수 측정에 필수)
      final activityStatus = await Permission.activityRecognition.request();
      final activityGranted = activityStatus.isGranted;
      
      // 알림 권한 요청 (걸음수 상태 알림에 필요)
      final notificationService = NotificationService();
      final notificationPermissions = await notificationService.checkAndRequestAllPermissions();
      final notificationGranted = notificationPermissions['notification'] ?? false;
      
      debugPrint('권한 요청 결과 - 활동 인식: $activityGranted, 알림: $notificationGranted');
      
      if (activityGranted && !_isInitialized) {
        // 권한을 얻은 후 초기화가 아직 완료되지 않았다면 초기화 재시도
        await initialize();
      }
      
      return {
        'activity': activityGranted,
        'notification': notificationGranted
      };
    } catch (e) {
      debugPrint('권한 요청 오류: $e');
      return {
        'activity': false,
        'notification': false
      };
    }
  }

  // 기존 requestPermission 메서드는 하위 호환성을 위해 유지
  // 활동 인식 권한만 요청하고 결과를 반환
  Future<bool> requestPermission() async {
    try {
      final permissions = await requestPermissions();
      return permissions['activity'] ?? false;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // 서비스 시작
  Future<bool> startService() async {
    try {
      // 아직 초기화되지 않았다면 초기화 실행
      if (!_isInitialized) {
        await initialize();
      }

      // 서비스 시작 (권한 요청은 호출자가 이미 requestPermissions()를 통해 처리)
      final result = await _methodChannel.invokeMethod<bool>(
        'startStepCounterService',
      );

      if (result == true) {
        _isServiceRunning = true;
        _serviceStatusController.add(_isServiceRunning);
        debugPrint('StepCounterManager: 걸음 수 서비스 시작 성공');
        return true;
      } else {
        debugPrint('StepCounterManager: 걸음 수 서비스 시작 실패');
        return false;
      }
    } catch (e) {
      debugPrint('StepCounterManager: 서비스 시작 중 오류 발생 - $e');
      _isServiceRunning = false;
      _serviceStatusController.add(_isServiceRunning);
      return false;
    }
  }

  // 서비스 중지
  Future<bool> stopService() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'stopStepCounterService',
      );

      if (result == true) {
        _isServiceRunning = false;
        _serviceStatusController.add(_isServiceRunning);
        debugPrint('StepCounterManager: 걸음 수 서비스 중지 성공');
        return true;
      } else {
        debugPrint('StepCounterManager: 걸음 수 서비스 중지 실패');
        return false;
      }
    } catch (e) {
      debugPrint('StepCounterManager: 서비스 중지 중 오류 발생 - $e');
      return false;
    }
  }

  // 현재 걸음 수 가져오기
  Future<int> getCurrentSteps() async {
    try {
      final steps = await _methodChannel.invokeMethod<int>('getStepCount');
      if (steps != null) {
        // 새로운 걸음 수가 0이고 현재 저장된 값이 0보다 크면 기존 값 유지
        if (steps > 0 || _currentSteps == 0) {
          _currentSteps = steps;
          _stepCountController.add(_currentSteps);
          debugPrint('현재 걸음 수 확인됨: $_currentSteps');
          
          // 목표 달성 확인 및 리워드 요청
          _checkGoalAchievement();
        } else {
          // 새 값이 0이고 현재 값이 0보다 크면 기존 값 유지하고 로그 출력
          debugPrint('걸음 수 값이 0으로 반환됨, 기존 값 $_currentSteps 유지');
        }
      }
      return _currentSteps;
    } catch (e) {
      debugPrint('Error getting step count: $e');
      return _currentSteps;
    }
  }

  // 목표 걸음 수 설정
  void setTargetSteps(int steps) {
    _targetSteps = steps;
    debugPrint('목표 걸음 수 설정됨: $_targetSteps');
    
    // 목표 변경 후 달성 여부 확인
    _checkGoalAchievement();
  }

  // 자원 해제
  void dispose() {
    _stepCountController.close();
    _serviceStatusController.close();
    _rewardStatusController.close();
  }
}
