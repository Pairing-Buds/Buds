// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../screens/character/models/character_data.dart';
import '../services/step_counter_manager.dart';
import 'character_provider.dart';

/// 마이페이지 상태를 관리하는 프로바이더
class MyPageProvider extends ChangeNotifier {
  final CharacterProvider _characterProvider;
  final StepCounterManager _stepCounterManager = StepCounterManager();

  // 스트림 구독 객체
  StreamSubscription<int>? _stepCountSubscription;
  StreamSubscription<bool>? _serviceStatusSubscription;

  // 기상 시간
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isWakeUpTimeLoaded = false;

  MyPageProvider(this._characterProvider) {
    // _initializeStepCounter();
    _loadWakeUpTime();
    // 생성 직후 저장된 걸음 수 로드
    _loadSavedSteps();
  }

  // 현재 선택된 캐릭터 인덱스
  int get selectedCharacterIndex =>
      _characterProvider.selectedCharacterIndex ?? 0;

  // 현재 선택된 캐릭터 이름
  String get selectedCharacterName =>
      CharacterData.getName(selectedCharacterIndex);

  // 현재 선택된 캐릭터 이미지 경로
  String get selectedCharacterImage =>
      CharacterData.getImage(selectedCharacterIndex);

  // 기상 시간
  TimeOfDay get wakeUpTime => _wakeUpTime;
  // 기상 시간이 로드되었는지 여부
  bool get isWakeUpTimeLoaded => _isWakeUpTimeLoaded;

  // 기상 시간 설정
  set wakeUpTime(TimeOfDay value) {
    _wakeUpTime = value;
    _saveWakeUpTime();
    notifyListeners();
  }

  // 기상 시간 저장
  Future<void> _saveWakeUpTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wake_up_hour', _wakeUpTime.hour);
      await prefs.setInt('wake_up_minute', _wakeUpTime.minute);

      // 저장 시간 함께 기록 (데이터 무결성 확인용)
      await prefs.setString('wake_up_saved_at', DateTime.now().toString());

      debugPrint('기상 시간 저장됨: ${_wakeUpTime.hour}:${_wakeUpTime.minute}');
      _isWakeUpTimeLoaded = true;
    } catch (e) {
      debugPrint('기상 시간 저장 실패: $e');
    }
  }

  // 기상 시간 불러오기
  Future<void> _loadWakeUpTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('wake_up_hour');
      final minute = prefs.getInt('wake_up_minute');
      final savedAt = prefs.getString('wake_up_saved_at');

      if (hour != null && minute != null) {
        _wakeUpTime = TimeOfDay(hour: hour, minute: minute);
        _isWakeUpTimeLoaded = true;
        debugPrint(
          '기상 시간 로드됨: ${_wakeUpTime.hour}:${_wakeUpTime.minute} (저장 시간: $savedAt)',
        );
        notifyListeners();
      } else {
        // 저장된 시간이 없는 경우 기본값으로 저장
        debugPrint('저장된 기상 시간이 없어 기본값(오전 7:00)을 사용합니다');
        _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
        _saveWakeUpTime(); // 기본값 저장
      }
    } catch (e) {
      debugPrint('기상 시간 로드 실패: $e');
      // 오류 발생 시 기본값 사용
      _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
      // 에러 발생 시 저장 시도
      Future.delayed(const Duration(seconds: 1), () {
        _saveWakeUpTime();
      });
    }
  }

  // 걸음 수 관련 속성
  int _currentSteps = 0;
  int _targetSteps = 6000;
  bool _isServiceRunning = false;
  DateTime _lastStepUpdateTime = DateTime.now();

  int get currentSteps => _currentSteps;
  int get targetSteps => _targetSteps;
  double get stepAchievementRate =>
      _targetSteps > 0 ? _currentSteps / _targetSteps : 0;
  bool get isServiceRunning => _isServiceRunning;
  DateTime get lastStepUpdateTime => _lastStepUpdateTime;

  // 저장된 걸음 수 로드
  Future<void> _loadSavedSteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSteps = prefs.getInt('user_current_steps');
      final savedTarget = prefs.getInt('user_target_steps');
      final lastUpdateStr = prefs.getString('user_steps_updated_at');

      if (savedSteps != null && savedSteps > 0) {
        _currentSteps = savedSteps;
        debugPrint(
          'MyPageProvider: 저장된 걸음 수 로드됨 - $_currentSteps (마지막 업데이트: $lastUpdateStr)',
        );
      }

      if (savedTarget != null) {
        _targetSteps = savedTarget;
        debugPrint('MyPageProvider: 저장된 목표 걸음 수 로드됨 - $_targetSteps');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('MyPageProvider: 저장된 걸음 수 로드 오류 - $e');
    }
  }

  // 걸음 수 초기화 및 구독
  Future<void> _initializeStepCounter() async {
    // 오류 처리 강화
    try {
      // 권한 확인
      bool hasPermission = await _stepCounterManager.checkPermission();

      if (!hasPermission) {
        // 권한 요청
        hasPermission = await _stepCounterManager.requestPermission();
        if (!hasPermission) {
          // 권한 거부 처리
          debugPrint('Permission denied for step counter');
          return;
        }
      }

      // 걸음 수 이벤트 구독
      _stepCountSubscription = _stepCounterManager.stepCountStream.listen(
        (steps) {
          updateSteps(steps);
        },
        onError: (error) {
          debugPrint('MyPageProvider: 걸음 수 스트림 오류 - $error');
        },
      );

      // 서비스 상태 구독
      _serviceStatusSubscription = _stepCounterManager.serviceStatusStream
          .listen(
            (isRunning) {
              _isServiceRunning = isRunning;
              notifyListeners();
              debugPrint('MyPageProvider: 서비스 상태 변경 - $isRunning');
            },
            onError: (error) {
              debugPrint('MyPageProvider: 서비스 상태 스트림 오류 - $error');
            },
          );

      // 초기 걸음 수 가져오기
      final steps = await _stepCounterManager.getCurrentSteps();
      updateSteps(steps);

      // 목표 걸음 수 설정
      _stepCounterManager.setTargetSteps(_targetSteps);

      // 서비스 시작
      await _stepCounterManager.startService();

      // 현재 값 업데이트
      _isServiceRunning = _stepCounterManager.isServiceRunning;
      notifyListeners();
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 측정 서비스 초기화 오류 - $e');
      // 오류 발생 시 1초 후 재시도
      Future.delayed(const Duration(seconds: 1), () {
        _retryInitializeStepCounter();
      });
    }
  }

  // 걸음 수 초기화 재시도
  Future<void> _retryInitializeStepCounter() async {
    try {
      debugPrint('MyPageProvider: 걸음 수 측정 서비스 초기화 재시도...');
      await _stepCounterManager.getCurrentSteps();
      _currentSteps = _stepCounterManager.currentSteps;
      await _stepCounterManager.startService();
      _isServiceRunning = _stepCounterManager.isServiceRunning;
      notifyListeners();
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 측정 서비스 초기화 재시도 실패 - $e');
    }
  }

  void updateSteps(int steps) {
    // 유효하지 않은 값(0이나 음수) 필터링
    if (steps <= 0 && _currentSteps > 0) {
      debugPrint(
        'MyPageProvider: 유효하지 않은 걸음 수 값($steps) 무시, 기존 값($_currentSteps) 유지',
      );
      return;
    }

    // 이미 동일한 걸음 수로 최근에 업데이트했는지 확인
    final now = DateTime.now();
    final timeDiff = now.difference(_lastStepUpdateTime).inSeconds;

    if (_currentSteps != steps || timeDiff > 5) {
      _currentSteps = steps;
      _lastStepUpdateTime = now;

      // 걸음 수 변경 시 SharedPreferences에 저장
      _saveCurrentSteps(steps);

      notifyListeners();
      debugPrint(
        'MyPageProvider: 걸음 수 업데이트 - $_currentSteps (시간: ${now.toIso8601String()})',
      );
    }
  }

  // 걸음 수를 SharedPreferences에 저장
  Future<void> _saveCurrentSteps(int steps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_current_steps', steps);
      await prefs.setString('user_steps_updated_at', DateTime.now().toString());
      debugPrint('MyPageProvider: 걸음 수 저장됨 - $steps');
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 저장 오류 - $e');
    }
  }

  void updateTargetSteps(int target) {
    if (_targetSteps != target) {
      _targetSteps = target;
      _stepCounterManager.setTargetSteps(target);
      // 목표 걸음 수 저장
      _saveTargetSteps(target);
      notifyListeners();
      debugPrint('MyPageProvider: 목표 걸음 수 업데이트 - $_targetSteps');
    }
  }

  // 목표 걸음 수를 SharedPreferences에 저장
  Future<void> _saveTargetSteps(int target) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_target_steps', target);
    } catch (e) {
      debugPrint('MyPageProvider: 목표 걸음 수 저장 오류 - $e');
    }
  }

  // 걸음수 포맷팅
  String formatSteps(int steps) {
    return '${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 보';
  }

  // 걸음 수 서비스 시작
  Future<void> startStepCounterService() async {
    try {
      final result = await _stepCounterManager.startService();
      if (result) {
        _isServiceRunning = true;
        notifyListeners();

        // 서비스 시작 후 최신 걸음 수 가져오기
        await Future.delayed(const Duration(milliseconds: 500));
        final steps = await _stepCounterManager.getCurrentSteps();
        updateSteps(steps);
      }
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 서비스 시작 실패 - $e');
    }
  }

  // 걸음 수 서비스 중지
  Future<void> stopStepCounterService() async {
    try {
      final result = await _stepCounterManager.stopService();
      if (result) {
        _isServiceRunning = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 서비스 중지 실패 - $e');
    }
  }

  // 걸음 수 강제 갱신
  Future<void> forceRefreshSteps() async {
    try {
      final steps = await _stepCounterManager.getCurrentSteps();
      updateSteps(steps);
      debugPrint('MyPageProvider: 걸음 수 강제 갱신 - $steps');
    } catch (e) {
      debugPrint('MyPageProvider: 걸음 수 강제 갱신 실패 - $e');
    }
  }

  // 서비스 상태 업데이트
  void updateServiceStatus(bool isRunning) {
    if (_isServiceRunning != isRunning) {
      _isServiceRunning = isRunning;
      notifyListeners();
      debugPrint('MyPageProvider: 서비스 상태 업데이트 - $isRunning');
    }
  }

  @override
  void dispose() {
    // 스트림 구독 해제
    _stepCountSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    super.dispose();
  }
}
