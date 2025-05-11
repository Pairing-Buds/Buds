import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 걸음 수 스트림 컨트롤러
  final _stepCountController = StreamController<int>.broadcast();
  Stream<int> get stepCountStream => _stepCountController.stream;

  // 서비스 상태 스트림 컨트롤러
  final _serviceStatusController = StreamController<bool>.broadcast();
  Stream<bool> get serviceStatusStream => _serviceStatusController.stream;

  // 걸음 수 getter
  int get currentSteps => _currentSteps;
  int get targetSteps => _targetSteps;
  bool get isServiceRunning => _isServiceRunning;
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
        }
      },
      onError: (error) {
        debugPrint('Step counter error: $error');
      },
    );

    _isEventListenerSet = true;
    debugPrint('걸음 수 이벤트 리스너 설정됨');
  }

  // 권한 확인
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

  // 권한 요청
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted && !_isInitialized) {
        // 권한을 얻은 후 초기화가 아직 완료되지 않았다면 초기화 재시도
        await initialize();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  // 서비스 시작
  Future<bool> startService() async {
    try {
      // 권한 확인
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        debugPrint('StepCounterManager: 권한이 없어 서비스를 시작할 수 없습니다.');
        final granted = await requestPermission();
        if (!granted) {
          return false;
        }
      }

      // 아직 초기화되지 않았다면 초기화 실행
      if (!_isInitialized) {
        await initialize();
      }

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
  }

  // 자원 해제
  void dispose() {
    _stepCountController.close();
    _serviceStatusController.close();
  }
}
