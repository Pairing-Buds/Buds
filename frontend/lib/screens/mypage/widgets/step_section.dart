// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/toast_bar.dart';
import '../../../providers/my_page_provider.dart';
import '../../../services/step_counter_manager.dart';
import '../../../services/step_reward_service.dart';

/// 걸음 수 섹션 위젯
class StepSection extends StatefulWidget {
  const StepSection({super.key});


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
  // 리워드 상태 구독
  StreamSubscription<Map<String, dynamic>>? _rewardStatusSubscription;
  // 걸음 수 매니저
  final StepCounterManager _stepCounterManager = StepCounterManager();
  // 리워드 서비스
  final StepRewardService _stepRewardService = StepRewardService();

  // 로컬 상태
  int _currentSteps = 0;
  bool _isServiceRunning = false;
  bool _showRewardButton = false;

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

            // 목표 달성 시 리워드 버튼 표시
            _checkGoalAchievement();

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

    // 리워드 상태 구독
    _rewardStatusSubscription = _stepCounterManager.rewardStatusStream.listen(
      (result) {
        if (mounted) {
          // 리워드 결과 알림 표시
          _showRewardResult(result);
        }
      },
      onError: (error) {
        debugPrint('StepSection: 리워드 상태 이벤트 오류 - $error');
      },
    );

    // 2초마다 걸음 수 확인 (UI 강제 갱신)
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    _rewardStatusSubscription?.cancel();
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
        
        // 목표 달성 확인
        _checkGoalAchievement();
      }
    } catch (e) {
      debugPrint('StepSection: 걸음 수 새로고침 오류 - $e');
    }
  }

  // 목표 달성 확인
  Future<void> _checkGoalAchievement() async {
    final myPageProvider = Provider.of<MyPageProvider>(
      context, 
      listen: false,
    );
    
    // 리워드 서비스를 통해 목표 달성 여부 확인
    final isAchieved = await _stepRewardService.checkStepGoalAchievement(
      _currentSteps, 
      myPageProvider.targetSteps
    );
    final isAlreadyRequested = _stepCounterManager.isRewardRequested;
    
    setState(() {
      _showRewardButton = isAchieved && !isAlreadyRequested;
    });
  }

  // 리워드 요청
  Future<void> _requestReward() async {
    try {
      final result = await _stepCounterManager.requestStepReward();
      debugPrint('StepSection: 리워드 요청 결과 - $result');
    } catch (e) {
      debugPrint('StepSection: 리워드 요청 오류 - $e');
    }
  }

  // 리워드 결과 알림 표시
  void _showRewardResult(Map<String, dynamic> result) {
    final message = result['message'] as String? ?? '알 수 없는 결과';
    final success = result['success'] as bool? ?? false;
    final isNewReward = result['isNewReward'] as bool? ?? false;
    
    // 리워드 버튼 상태 업데이트
    setState(() {
      _showRewardButton = false;
    });
    
    // 알림 표시
    if (mounted) {
      Toast(
        context,
        message,
        icon: Icon(
          isNewReward ? Icons.star : Icons.info,
          color: isNewReward ? Colors.yellow : Colors.white,
        ),
      );
    }
  }

  // 리워드 요청 상태 초기화 (테스트용)
  Future<void> _resetRewardRequestStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_step_reward_date');
      
      // StepCounterManager의 상태도 업데이트하기 위해 앱 재시작 필요
      Toast(
        context,
        '리워드 상태가 초기화되었습니다. 앱을 재시작하면 적용됩니다.',
        icon: const Icon(Icons.refresh, color: Colors.red),
      );
    } catch (e) {
      debugPrint('리워드 상태 초기화 오류: $e');
      Toast(
        context,
        '리워드 상태 초기화 실패: $e',
        icon: const Icon(Icons.error, color: Colors.red),
      );
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
      debugPrint('StepSection: 서비스 시작 시도...');
      
      // 활동 인식 및 알림 권한 함께 요청 (걸음수 측정 및 상태 알림 기능을 위함)
      final permissions = await _stepCounterManager.requestPermissions();
      final activityGranted = permissions['activity'] ?? false;
      final notificationGranted = permissions['notification'] ?? false;
      
      // 권한 결과 로그
      debugPrint('StepSection: 권한 요청 결과 - 활동 인식: $activityGranted, 알림: $notificationGranted');
      
      // 활동 인식 권한이 없으면 서비스를 시작할 수 없음 (필수 권한)
      if (!activityGranted) {
        if (mounted) {
          Toast(
            context,
            '걸음 수 측정을 위해 활동 인식 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
        return;
      }
      
      // 알림 권한이 없으면 경고만 표시 (선택적 권한이므로 서비스는 시작 가능)
      if (!notificationGranted && mounted) {
        Toast(
          context,
          '걸음 수 알림을 받기 위해 알림 권한을 허용하는 것이 좋습니다.',
          icon: const Icon(Icons.warning, color: Colors.orange),
        );
      }
      
      // 필요한 권한이 확보되었으므로 서비스 시작
      final success = await _stepCounterManager.startService();

      if (success) {
        debugPrint('StepSection: 서비스 시작 성공');
        // 서비스 시작 후 즉시 걸음 수 갱신
        await _refreshStepCount();
        
        // 성공 메시지 표시
        if (mounted) {
          Toast(context, '걸음 수 측정이 시작되었습니다.');
        }
      } else {
        debugPrint('StepSection: 서비스 시작 실패');
        if (mounted) {
          Toast(
            context,
            '걸음 수 측정 서비스를 시작할 수 없습니다. 권한을 확인해주세요.',
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('StepSection: 서비스 시작 오류 - $e');
      if (mounted) {
        Toast(
          context,
          '걸음 수 측정 서비스 시작 중 오류가 발생했습니다.',
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    }
  }

  // 걸음 수 서비스 중지
  Future<void> _stopStepCounterService() async {
    try {
      debugPrint('StepSection: 서비스 중지 시도...');
      final success = await _stepCounterManager.stopService();

      if (success) {
        debugPrint('StepSection: 서비스 중지 성공');
        // 서비스 상태 즉시 반영
        _checkServiceRunning();
      } else {
        debugPrint('StepSection: 서비스 중지 실패');
        if (mounted) {
          Toast(context, '걸음 수 측정 서비스를 중지할 수 없습니다.');
        }
      }
    } catch (e) {
      debugPrint('StepSection: 서비스 중지 오류 - $e');
      if (mounted) {
        Toast(
          context,
          '걸음 수 측정 서비스 중지 중 오류가 발생했습니다.',
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
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
        // 리워드 버튼 (목표 달성 시에만 표시)
        if (_showRewardButton)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: _requestReward,
              icon: const Icon(Icons.card_giftcard, color: Colors.white),
              label: const Text('걸음수 목표 달성 리워드 받기', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        // 테스트용 버튼들 (디버그 모드에서만 표시)
        if (kDebugMode)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                const Divider(height: 16, thickness: 1),
                const Text('테스트 도구', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // 걸음수를 목표치로 설정 (테스트용)
                          final myPageProvider = Provider.of<MyPageProvider>(
                            context, 
                            listen: false,
                          );
                          final targetSteps = myPageProvider.targetSteps;
                          setState(() {
                            _currentSteps = targetSteps;
                          });
                          myPageProvider.updateSteps(targetSteps);
                          await _checkGoalAchievement();
                          Toast(context, '걸음수를 목표치($targetSteps)로 설정했습니다');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('목표 걸음수 달성 (테스트)', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // 리워드 API 직접 호출 (테스트용)
                          final myPageProvider = Provider.of<MyPageProvider>(
                            context, 
                            listen: false,
                          );
                          final result = await _stepRewardService.requestStepReward(
                            currentSteps: _currentSteps,
                            targetSteps: myPageProvider.targetSteps
                          );
                          _showRewardResult(result);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('리워드 API 직접 호출', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 리워드 요청 상태 초기화 (테스트용)
                          _resetRewardRequestStatus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('리워드 상태 초기화', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        // 서비스 상태 표시 및 제어 버튼
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
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
