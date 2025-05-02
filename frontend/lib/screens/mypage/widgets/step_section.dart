import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../providers/my_page_provider.dart';
import '../../../services/step_counter_manager.dart';
import 'package:buds/config/theme.dart';

/// 걸음 수 섹션 위젯
class StepSection extends StatefulWidget {
  const StepSection({Key? key}) : super(key: key);

  @override
  State<StepSection> createState() => _StepSectionState();
}

class _StepSectionState extends State<StepSection> {
  // 걸음 수 표시를 위한 타이머
  Timer? _refreshTimer;
  // 걸음 수 구독
  StreamSubscription<int>? _stepCountSubscription;
  // 서비스 상태 구독
  StreamSubscription<bool>? _serviceStatusSubscription;
  // 걸음 수 매니저
  final StepCounterManager _stepCounterManager = StepCounterManager();

  // 로컬 상태
  int _currentSteps = 0;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();

    debugPrint('StepSection: 초기화 중...');

    // 초기 데이터 즉시 로딩 시도 (delay 없이)
    _refreshStepCount();

    // 걸음 수 이벤트 구독
    _stepCountSubscription = _stepCounterManager.stepCountStream.listen(
      (steps) {
        // 마운트된 상태에서만 업데이트
        if (mounted) {
          setState(() {
            _currentSteps = steps;

            // Provider에게 갱신 요청
            final myPageProvider = Provider.of<MyPageProvider>(
              context,
              listen: false,
            );
            myPageProvider.updateSteps(steps);

            debugPrint('StepSection: 걸음 수 이벤트 수신 - $steps');
          });
        }
      },
      onError: (error) {
        debugPrint('StepSection: 걸음 수 이벤트 오류 - $error');
      },
    );

    // 서비스 상태 구독
    _serviceStatusSubscription = _stepCounterManager.serviceStatusStream.listen(
      (isRunning) {
        if (mounted) {
          setState(() {
            _isServiceRunning = isRunning;
            debugPrint('StepSection: 서비스 상태 변경 - $isRunning');
          });
        }
      },
      onError: (error) {
        debugPrint('StepSection: 서비스 상태 이벤트 오류 - $error');
      },
    );

    // 2초마다 걸음 수 확인 (UI 강제 갱신)
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _refreshStepCount();
    });
  }

  @override
  void dispose() {
    // 타이머 정리
    _refreshTimer?.cancel();
    // 구독 정리
    _stepCountSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    debugPrint('StepSection: 자원 해제됨');
    super.dispose();
  }

  // 걸음 수 새로고침
  Future<void> _refreshStepCount() async {
    try {
      // 서비스 상태 확인
      _checkServiceRunning();

      // 걸음 수 직접 가져오기
      final steps = await _stepCounterManager.getCurrentSteps();

      // 유효하지 않은 값(0이나 음수) 필터링
      if (steps <= 0 && _currentSteps > 0) {
        debugPrint(
          'StepSection: 유효하지 않은 걸음 수 값($steps) 무시, 기존 값($_currentSteps) 유지',
        );
        return;
      }

      if (mounted) {
        setState(() {
          _currentSteps = steps;
        });

        final myPageProvider = Provider.of<MyPageProvider>(
          context,
          listen: false,
        );
        myPageProvider.updateSteps(steps);
        debugPrint('StepSection: 걸음 수 새로고침 - $_currentSteps');
      }
    } catch (e) {
      debugPrint('StepSection: 걸음 수 새로고침 오류 - $e');
    }
  }

  // 서비스 상태 확인
  Future<void> _checkServiceRunning() async {
    try {
      // 서비스가 실행 중인지 확인
      final isRunning = _stepCounterManager.isServiceRunning;
      if (mounted && _isServiceRunning != isRunning) {
        setState(() {
          _isServiceRunning = isRunning;
        });
      }
    } catch (e) {
      debugPrint('StepSection: 서비스 상태 확인 오류 - $e');
    }
  }

  // 걸음 수 서비스 시작
  Future<void> _startStepCounterService() async {
    try {
      await _stepCounterManager.startService();
      // 서비스 시작 후 즉시 걸음 수 갱신
      await _refreshStepCount();
    } catch (e) {
      debugPrint('StepSection: 서비스 시작 오류 - $e');
    }
  }

  // 걸음 수 서비스 중지
  Future<void> _stopStepCounterService() async {
    try {
      await _stepCounterManager.stopService();
      // 서비스 상태 즉시 반영
      _checkServiceRunning();
    } catch (e) {
      debugPrint('StepSection: 서비스 중지 오류 - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider로부터 데이터 구독
    final myPageProvider = Provider.of<MyPageProvider>(context);

    // 프로바이더 데이터와 로컬 상태 중 최신 걸음 수 사용
    final displaySteps =
        myPageProvider.currentSteps > _currentSteps
            ? myPageProvider.currentSteps
            : _currentSteps;

    // 화면에 표시되는 서비스 상태는 로컬 상태와 프로바이더 상태 중 하나라도 실행 중이면 실행 중으로 표시
    final isRunning = myPageProvider.isServiceRunning || _isServiceRunning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '걸음 수',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // 새로고침 버튼 추가
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: _refreshStepCount,
              tooltip: '걸음 수 새로고침',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.green.shade400,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${myPageProvider.formatSteps(displaySteps)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '목표: ${myPageProvider.formatSteps(myPageProvider.targetSteps)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: myPageProvider.stepAchievementRate,
                    backgroundColor: Colors.green.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade400,
                    ),
                    strokeWidth: 6,
                  ),
                  Text(
                    '${(myPageProvider.stepAchievementRate * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 서비스 상태 표시 및 제어 버튼
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRunning ? '걸음 수 측정 중...' : '걸음 수 측정 중지됨',
                style: TextStyle(
                  color: isRunning ? Color(0xFF388E3C) : Color(0xFFFF5A5A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (isRunning) {
                    await _stopStepCounterService();
                  } else {
                    await _startStepCounterService();
                  }
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    isRunning
                        ? const Color(0xFF388E3C)
                        : const Color(0xFFFF5A5A),
                  ),
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.transparent,
                  ),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  isRunning ? '중지' : '시작',
                  style: TextStyle(
                    color:
                        isRunning
                            ? const Color(0xFF388E3C)
                            : const Color(0xFFFF5A5A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
