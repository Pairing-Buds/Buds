// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/services/notification_service.dart';

import 'package:buds/main.dart'; // navigatorKey, startedFromNotification, initialRoute 접근을 위한 import
import 'dart:async'; // Timer 클래스를 위한 import
import 'package:buds/services/lock_screen_manager.dart'; // 잠금화면 관리자 추가
import 'package:buds/services/wake_up_service.dart'; // 추가
import 'package:buds/services/auth_service.dart'; // 추가
import 'package:buds/widgets/toast_bar.dart';

/// 알람이 울릴 때 표시되는 전체 화면
class AlarmScreen extends StatefulWidget {
  final String title;
  final String message;
  final int notificationId;

  const AlarmScreen({
    super.key,
    required this.title,
    required this.message,
    required this.notificationId,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  // 현재 시간을 저장하는 변수
  late DateTime _currentTime;
  // 타이머
  late Timer _timer;
  // 잠금화면 관리자
  final LockScreenManager _lockScreenManager = LockScreenManager();

  @override
  void initState() {
    super.initState();

    // 현재 시간 초기화
    _currentTime = DateTime.now();

    // 1초마다 시간 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);

    // 앱 라이프사이클 변화 관찰 등록
    WidgetsBinding.instance.addObserver(this);

    // 화면 표시 시 잠금화면 바이패스 활성화
    _enableLockScreenBypass();

    // 알람 화면 시작 로그
    debugPrint('======================================');
    debugPrint('알람 화면이 시작되었습니다.');
    debugPrint('시작 시간: ${DateTime.now().toString()}');
    debugPrint('알람 ID: ${widget.notificationId}');
    debugPrint('알람 제목: ${widget.title}');
    debugPrint('알람 메시지: ${widget.message}');
    debugPrint('======================================');
  }

  @override
  void dispose() {
    // 타이머 취소
    _timer.cancel();

    // 앱 라이프사이클 변화 관찰 해제
    WidgetsBinding.instance.removeObserver(this);

    // 화면 종료 시 잠금화면 바이패스 비활성화
    _disableLockScreenBypass();

    // 알람 화면 종료 로그
    debugPrint('======================================');
    debugPrint('알람 화면이 종료되었습니다.');
    debugPrint('종료 시간: ${DateTime.now().toString()}');
    debugPrint('======================================');

    super.dispose();
  }

  // 잠금화면 바이패스 활성화
  Future<void> _enableLockScreenBypass() async {
    try {
      await _lockScreenManager.enableLockScreenBypass();
      debugPrint('알람 화면: 잠금화면 바이패스 활성화 요청 완료');
    } catch (e) {
      debugPrint('알람 화면: 잠금화면 바이패스 활성화 오류: $e');
    }
  }

  // 잠금화면 바이패스 비활성화
  Future<void> _disableLockScreenBypass() async {
    try {
      await _lockScreenManager.disableLockScreenBypass();
      debugPrint('알람 화면: 잠금화면 바이패스 비활성화 요청 완료');
    } catch (e) {
      debugPrint('알람 화면: 잠금화면 바이패스 비활성화 오류: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 상태 변화에 따른 처리
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 현재 시간 갱신 및 잠금화면 바이패스 활성화
      setState(() {
        _currentTime = DateTime.now();
      });
      _enableLockScreenBypass();
      debugPrint('알람 화면: 앱이 재개됨 - 잠금화면 바이패스 활성화');
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 갈 때 처리
      debugPrint('알람 화면: 앱이 일시정지됨');
    }
  }

  // 시간 업데이트 함수
  void _updateTime(Timer timer) {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // 상단 시간 표시
            Text(
              _getCurrentTimeFormatted(),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 알람 메시지
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // 부가 메시지
            Text(
              widget.message,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),

            const Spacer(flex: 2),

            // 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 알람 끄기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _dismissAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '알람 끄기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5분 후 다시 알림 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _snoozeAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '5분 후 다시 알림',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // 현재 시간을 포맷팅하여 반환
  String _getCurrentTimeFormatted() {
    final hour = _currentTime.hour;
    final minute = _currentTime.minute;

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$period $displayHour:$displayMinute';
  }

  // 알람 끄기
  void _dismissAlarm() async {
    try {
      // 기상 시간 검증 API 호출
      final wakeUpService = WakeUpService();
      final result = await wakeUpService.verifyWakeUp();

      // 알람 종료 로그
      debugPrint('======================================');
      debugPrint('사용자가 알람을 종료했습니다.');
      debugPrint('알람 종료 시간: ${DateTime.now().toString()}');
      debugPrint('======================================');

      // 알림 취소
      await NotificationService().cancelAllAlarms();

      // 알림을 통한 시작 상태 초기화 (완전히 모든 상태 초기화)
      await NotificationService().deactivateAlarm();

      // 잠금화면 바이패스 비활성화
      await _disableLockScreenBypass();

      if (mounted) {
        // 결과 메시지 표시
        Toast(
          context,
          result['message'],
          icon: Icon(
            Icons.check_circle,
            color: result['success'] ? Colors.green : Colors.red,
            size: 20,
          ),
        );

        // 로그인 상태 확인
        final authService = DioAuthService();
        final hasValidCookies = await authService.checkCookies();

        if (hasValidCookies) {
          // 로그인된 상태면 메인 화면으로
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/main', (route) => false);
        } else {
          // 로그인되지 않은 상태면 로그인 화면으로
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        Toast(context, '오류가 발생했습니다: $e', icon: const Icon(Icons.error, color: Colors.red, size: 20));
      }
    }
  }

  // 5분 후 다시 알림
  void _snoozeAlarm() async {
    try {
      // 알람 스누즈 로그
      debugPrint('======================================');
      debugPrint('사용자가 알람을 5분 후로 스누즈했습니다.');
      debugPrint('스누즈 요청 시간: ${DateTime.now().toString()}');
      debugPrint('======================================');

      // 스누즈 함수 호출
      await NotificationService().snoozeAlarm();

      // 알림을 통한 시작 상태 초기화 (완전히 모든 상태 초기화)
      await NotificationService().deactivateAlarm();

      // 잠금화면 바이패스 비활성화
      await _disableLockScreenBypass();

      if (mounted) {
        // 로그인 상태 확인
        final authService = DioAuthService();
        final hasValidCookies = await authService.checkCookies();

        if (hasValidCookies) {
          // 로그인된 상태면 메인 화면으로
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/main', (route) => false);
        } else {
          // 로그인되지 않은 상태면 로그인 화면으로
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        Toast(context, '오류가 발생했습니다: $e', icon: const Icon(Icons.error, color: Colors.red, size: 20));
      }
    }
  }
}
