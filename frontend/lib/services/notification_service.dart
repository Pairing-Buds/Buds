import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:buds/main.dart'; // navigatorKey 사용을 위한 import
import 'package:flutter/services.dart'; // MethodChannel 사용을 위한 import

/// 알림 서비스 클래스
class NotificationService {
  // 싱글톤 패턴 구현
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 알림 플러그인 인스턴스
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 네이티브 코드 호출을 위한 메서드 채널
  static const platform = MethodChannel('com.buds.app/battery_optimization');

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    try {
      // timezone 초기화
      tz_data.initializeTimeZones();

      // 한국 시간대 설정
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      debugPrint('NotificationService: 시간대 초기화 완료');

      // 앱 시작 시 알림 상태 확인
      debugPrint('NotificationService: 알림을 통한 시작 여부: $startedFromNotification');

      // Android 설정 - 기본 Android 아이콘 사용
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/island');

      // 초기화 설정
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      // 플러그인 초기화
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      debugPrint('NotificationService: 초기화 완료');

      // 알림 채널 설정
      await _setupAlarmNotificationChannel();

      // 테스트 알림 ID만 취소 (실제 사용자 알림은 유지)
      try {
        // 999는 테스트 알림 ID
        // 0은 기상 알람, 1은 스누즈 알람 ID
        // 테스트 알림만 취소하고 실제 알람은 유지
        final List<int> pendingNotificationIds =
            (await _flutterLocalNotificationsPlugin
                    .pendingNotificationRequests())
                .map((notification) => notification.id)
                .toList();

        debugPrint('예약된 알림 ID 목록: $pendingNotificationIds');

        if (pendingNotificationIds.contains(999)) {
          await _flutterLocalNotificationsPlugin.cancel(999);
          debugPrint('NotificationService: 테스트 알림(ID: 999) 취소 완료');
        } else {
          debugPrint('NotificationService: 취소할 테스트 알림(ID: 999) 없음');
        }
      } catch (e) {
        debugPrint('NotificationService: 테스트 알림 취소 실패: $e');
      }

      // 보류 중인 알림(미래에 예약된 알림)을 확인하여 처리
      await _checkPendingNotifications();

      // 배터리 최적화 설정 무시 요청
      _requestBatteryOptimizationDisable();

      // 앱이 알림을 통해 시작되었는지 확인 (알림을 탭했을 때만 알람 화면으로 이동)
      // 이 로직은 현재 구현되어 있지 않고, 알림을 통해 앱이 시작되면 notificationTapBackground에서 처리됨
    } catch (e) {
      debugPrint('NotificationService 초기화 오류: $e');
    }
  }

  /// 보류 중인 알림 확인 및 처리
  Future<void> _checkPendingNotifications() async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      final List<PendingNotificationRequest> pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      debugPrint('대기 중인 알림 수: ${pendingNotificationRequests.length}');

      // 활성화된 알림 확인 (Android에서만 작동)
      try {
        final activeNotifications = await getActiveNotifications();
        debugPrint('활성화된 알림 수: ${activeNotifications.length}');

        if (activeNotifications.isNotEmpty) {
          debugPrint('활성화된 알림 세부 정보:');
          for (var notification in activeNotifications) {
            debugPrint(
              '알림 ID: ${notification.id}, 제목: ${notification.title}, 채널: ${notification.channelId}',
            );
          }

          // 알람 관련 알림이 있는지 확인 (ID 0 또는 1)
          bool hasAlarmNotification = activeNotifications.any(
            (notification) => notification.id == 0 || notification.id == 1,
          );

          debugPrint('알람 관련 알림 존재: $hasAlarmNotification');

          // 알람 관련 알림이 있는 경우에만 알람 화면으로 이동
          if (hasAlarmNotification) {
            debugPrint('알람 관련 알림이 발견되어 알람 화면으로 이동합니다.');
            Future.delayed(const Duration(seconds: 2), () {
              navigateToAlarmScreen();
            });
          } else {
            debugPrint('알람 관련 알림이 없어 알람 화면으로 이동하지 않습니다.');
          }
        } else {
          debugPrint('활성화된 알림이 없어 알람 화면으로 이동하지 않습니다.');
        }
      } catch (e) {
        debugPrint('활성화된 알림 확인 중 오류 발생: $e');
      }
    } catch (e) {
      debugPrint('보류 중인 알림 확인 중 오류 발생: $e');
    }
  }

  /// 알림 응답 처리
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('======================================');
    debugPrint(
      '알림 응답 수신: ID=${response.id}, actionId=${response.actionId}, payload=${response.payload}',
    );
    debugPrint('알림 응답 시간: ${DateTime.now().toString()}');

    // 알람 관련 알림인 경우 (ID 또는 페이로드로 확인)
    if (response.id == 0 ||
        response.id == 1 ||
        response.id == 100 ||
        response.payload == 'alarm' ||
        response.payload == 'alarm_snooze' ||
        response.payload == 'alarm_test') {
      debugPrint('알람 관련 알림이 탭되었습니다. 알람 화면으로 이동합니다.');

      // 알람 화면으로 즉시 이동
      navigateToAlarmScreen();
    } else {
      debugPrint('알람 관련 알림이 아닌 일반 알림이 탭되었습니다.');
    }
    debugPrint('======================================');
  }

  /// 알람 화면으로 이동
  void navigateToAlarmScreen() {
    // 메인 스레드에서 실행하여 UI 업데이트 보장
    Future.microtask(() {
      if (navigatorKey.currentState != null) {
        try {
          // 플래그 설정 (메인.dart에서 참조)
          startedFromNotification = true;

          // 알람 화면으로 이동
          navigatorKey.currentState!.pushNamed('/alarm');
          debugPrint('알람 화면 이동 성공');
        } catch (e) {
          debugPrint('알람 화면 이동 오류: $e');
          // 오류 발생 시 1초 후 다시 시도
          Future.delayed(const Duration(seconds: 1), () {
            try {
              if (navigatorKey.currentState != null) {
                navigatorKey.currentState!.pushNamed('/alarm');
                debugPrint('알람 화면 이동 재시도 성공');
              }
            } catch (e) {
              debugPrint('알람 화면 이동 재시도 실패: $e');
            }
          });
        }
      } else {
        debugPrint('알람 화면 이동 실패: NavigatorState가 null입니다');
      }
    });
  }

  /// 알람 화면으로 이동하는 메서드 (내부용)
  void _showAlarmScreen(int notificationId) {
    navigateToAlarmScreen();
  }

  /// 알람 상태 활성화
  void _activateAlarm() {
    // 이 메서드는 현재 사용되지 않습니다만 향후 확장성을 위해 유지
    debugPrint('알람 상태 활성화됨');
  }

  /// 알람 상태 비활성화
  void deactivateAlarm() {
    // 이 메서드는 현재 사용되지 않습니다만 향후 확장성을 위해 유지
    debugPrint('알람 상태 비활성화됨');
  }

  /// 알람 관련 알림 채널 설정 (일반 알림만 사용)
  Future<void> _setupAlarmNotificationChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      // 기본 알림 권한만 요청
      await androidImplementation.requestNotificationsPermission();

      // 일반 알림 채널만 등록 (기기 기본 설정 사용)
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          'alarm_channel_standard',
          '알람 채널 (표준)',
          description: '기본 알람 알림을 위한 채널입니다',
          importance: Importance.high,
          showBadge: true,
        ),
      );

      debugPrint('알람 알림 채널 설정 완료 (기기 기본 설정 사용)');
    }
  }

  /// 알람 화면으로 바로 이동
  void showAlarmScreen() {
    _showAlarmScreen(0);
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    try {
      // Android 13 이상
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // 알림 권한 요청
        bool? permissionGranted;
        try {
          permissionGranted =
              await androidImplementation.requestNotificationsPermission();
          debugPrint('알림 권한 상태: $permissionGranted');
        } catch (e) {
          debugPrint('알림 권한 요청 실패: $e');
        }

        // 정확한 알람 권한 요청
        bool? canScheduleExact;
        try {
          canScheduleExact =
              await androidImplementation.canScheduleExactNotifications();
          debugPrint('정확한 알람 예약 가능 여부: $canScheduleExact');

          if (canScheduleExact == false) {
            debugPrint('정확한 알람 권한이 필요합니다');
            // 정확한 알림을 위한 권한 요청
            try {
              // 사용자에게 권한이 필요함을 알리고 설정으로 이동하도록 안내
              bool? userResponse = await _showAlarmPermissionDialog();
              if (userResponse == true) {
                await androidImplementation.requestExactAlarmsPermission();
                debugPrint('정확한 알람 권한 요청 완료');
              } else {
                debugPrint('사용자가 정확한 알람 권한 요청을 거부했습니다');
              }
            } catch (e) {
              debugPrint('정확한 알람 권한 요청 실패: $e');
            }

            // 기본 알림 권한만 요청 (잠금 화면 위 표시 권한 요청 제거)
            try {
              await androidImplementation.requestNotificationsPermission();
              debugPrint('알림 권한 요청 완료');
            } catch (e) {
              debugPrint('알림 권한 요청 실패: $e');
            }
          }
        } catch (e) {
          debugPrint('정확한 알람 권한 확인 실패: $e');
        }

        return permissionGranted ?? false;
      }

      return true; // 기본값
    } catch (e) {
      debugPrint('알림 권한 요청 오류: $e');
      return false;
    }
  }

  /// 정확한 알람 권한 요청 다이얼로그
  Future<bool?> _showAlarmPermissionDialog() async {
    if (navigatorKey.currentContext == null) {
      debugPrint('알람 권한 다이얼로그 표시 실패: context가 null입니다');
      return false;
    }

    return await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('정확한 알람 권한 필요'),
          content: const Text(
            '정확한 시간에 알람이 작동하려면 "정확한 알람 예약" 권한이 필요합니다.\n\n'
            '설정 화면으로 이동하여 권한을 허용해 주세요.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('나중에'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('설정으로 이동'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// 배터리 최적화 설정 무시 요청
  Future<void> _requestBatteryOptimizationDisable() async {
    try {
      final bool? result = await platform.invokeMethod<bool>(
        'requestBatteryOptimizationDisable',
      );
      debugPrint('배터리 최적화 설정 무시 요청 결과: $result');
    } on PlatformException catch (e) {
      debugPrint('배터리 최적화 설정 무시 요청 오류: ${e.message}');
    } catch (e) {
      debugPrint('배터리 최적화 설정 무시 요청 중 예상치 못한 오류: $e');
    }
  }

  /// 기상 알람 예약
  Future<void> scheduleWakeUpAlarm(TimeOfDay time) async {
    // 이전 알람 취소
    await cancelWakeUpAlarm();

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel', // 채널 ID
      '기상 알람', // 채널 이름
      description: '기상 시간을 알려주는 알림입니다', // 채널 설명
      importance: Importance.high,
      // sound: const RawResourceAndroidNotificationSound('alarm_sound'), // TODO: 알람 소리 파일 추가 후 주석 해제
    );

    try {
      // 채널 등록
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // 일반 알림 설정 (전체 화면 인텐트 완전히 비활성화)
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        // sound: channel.sound, // TODO: 알람 소리 파일 추가 후 주석 해제
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        autoCancel: true, // 탭하면 자동으로 사라짐
        showWhen: true, // 시간 표시
      );

      // 알림 세부 설정
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // 지정된 시간으로 변환
      final now = DateTime.now();

      // 오늘 날짜의 설정된 시간
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // 이미 지난 시간이면, 내일로 설정
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // timezone 변환
      final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      // 현재 시간과 알람 시간의 차이 계산
      final difference = scheduledDateTime.difference(
        tz.TZDateTime.now(tz.local),
      );
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      // 알람 시간 정보 로그 출력
      debugPrint('======================================');
      debugPrint('알람 설정 정보:');
      debugPrint('설정된 시간: ${time.hour}시 ${time.minute}분');
      debugPrint(
        '알람 예정 시간: ${scheduledDateTime.year}년 ${scheduledDateTime.month}월 ${scheduledDateTime.day}일 ${scheduledDateTime.hour}시 ${scheduledDateTime.minute}분',
      );
      debugPrint('현재 시간으로부터: $hours시간 $minutes분 후');
      debugPrint('======================================');

      // 알림 예약 (앱이 종료되어도 알람이 작동하도록 설정)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID
        '기상 시간입니다',
        '일어날 시간이에요! 눌러서 알람 화면으로 이동하세요.',
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // 앱이 종료되어도 작동
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복을 위한 설정
        payload: 'alarm', // 알림 페이로드 (알람 구분용)
      );
      debugPrint('알람 예약 성공 (exactAllowWhileIdle 모드)');

      // 테스트용 알림 (1분 후 테스트 알림) - 개발 중에만 활성화하고 배포 시 주석 처리
      // false로 변경하여 테스트 알림 비활성화 가능
      bool enableTestNotification = false; // 테스트 알림 비활성화
      if (enableTestNotification) {
        try {
          final testTime = tz.TZDateTime.now(
            tz.local,
          ).add(const Duration(minutes: 1));

          await _flutterLocalNotificationsPlugin.zonedSchedule(
            999, // 테스트용 ID (다른 알림과 충돌하지 않는 ID 사용)
            '테스트 알림',
            '이 알림이 보이면 알림 시스템이 작동 중입니다. 눌러서 확인하세요.',
            testTime,
            notificationDetails,
            androidScheduleMode:
                AndroidScheduleMode.exactAllowWhileIdle, // 앱이 종료되어도 작동
            payload: 'alarm_test', // 테스트용 페이로드
          );
          debugPrint('테스트 알림 예약 성공 (1분 후, exactAllowWhileIdle 모드)');
        } catch (e) {
          debugPrint('테스트 알림 예약 실패: $e');
        }
      } else {
        debugPrint('테스트 알림이 비활성화되었습니다.');
      }

      // 알람 설정 후 배터리 최적화 무시 요청
      _requestBatteryOptimizationDisable();
    } catch (e) {
      debugPrint('알람 예약 실패: $e');
      rethrow;
    }
  }

  /// 기상 알람 취소
  Future<void> cancelWakeUpAlarm() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(0);
      // 스누즈 알람도 함께 취소
      await _flutterLocalNotificationsPlugin.cancel(1);
      // 테스트 알람도 취소
      await _flutterLocalNotificationsPlugin.cancel(999);

      debugPrint('======================================');
      debugPrint('모든 알람 취소 완료');
      debugPrint('- 기본 알람 (ID: 0) 취소됨');
      debugPrint('- 스누즈 알람 (ID: 1) 취소됨');
      debugPrint('- 테스트 알람 (ID: 999) 취소됨');
      debugPrint('취소 시간: ${DateTime.now().toString()}');
      debugPrint('======================================');
    } catch (e) {
      debugPrint('알람 취소 실패: $e');
    }
  }

  /// 알림 탭 이벤트 처리
  void _onNotificationTap(NotificationResponse response) {
    // 알림 탭 시 처리할 내용
    if (response.actionId == 'snooze') {
      snoozeAlarm();
    } else {
      // 알람 화면으로 이동
      _showAlarmScreen(response.id ?? 0);
    }
  }

  /// 5분 후 다시 알림 (공개 메서드)
  Future<void> snoozeAlarm() async {
    await _snoozeAlarm();
  }

  /// 5분 후 다시 알림 (내부 구현)
  Future<void> _snoozeAlarm() async {
    try {
      // 현재 시간에서 5분 후에 알림 예약
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDateTime = now.add(const Duration(minutes: 5));

      // 일반 알림 설정 (전체 화면 인텐트 완전히 비활성화)
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'wake_up_alarm_snooze',
        '기상 알람 (다시 알림)',
        channelDescription: '다시 울리는 기상 알람입니다',
        importance: Importance.high,
        priority: Priority.high,
        // sound: const RawResourceAndroidNotificationSound('alarm_sound'), // TODO: 알람 소리 파일 추가 후 주석 해제
        visibility: NotificationVisibility.public, // 잠금화면에서 표시 설정
        category: AndroidNotificationCategory.alarm,
        autoCancel: true, // 탭하면 자동으로 사라짐
        showWhen: true, // 시간 표시
      );

      // 알림 세부 설정
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // 스누즈용 다른 ID 사용
        '기상 알람 (다시 알림)',
        '5분이 지났습니다. 일어날 시간이에요! 눌러서 알람 화면으로 이동하세요.',
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'alarm_snooze', // 알림 페이로드 (스누즈 알람 구분용)
      );

      // 알람 상태 비활성화 (스누즈 동안은 알람 화면 표시하지 않음)
      deactivateAlarm();

      // 스누즈 알람 로그 출력
      debugPrint('======================================');
      debugPrint('스누즈 알람 설정 완료');
      debugPrint('현재 시간: ${now.toString()}');
      debugPrint('알람 예정 시간: ${scheduledDateTime.toString()} (5분 후)');
      debugPrint('======================================');
    } catch (e) {
      debugPrint('스누즈 알람 설정 실패: $e');
    }
  }

  /// 활성화된 알림 목록 가져오기
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      final androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        return await androidImplementation.getActiveNotifications();
      }
    } catch (e) {
      debugPrint('활성화된 알림 목록 가져오기 실패: $e');
    }

    return [];
  }

  /// 즉시 테스트 알림 표시 (공개 메서드)
  Future<void> showImmediateNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        100, // 테스트 알림 ID
        '테스트 알림',
        '알람 기능 테스트입니다. 탭하여 알람 화면으로 이동하세요.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            '테스트 알림 채널',
            channelDescription: '알림 테스트용 채널',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: 'alarm_test',
      );

      debugPrint('======================================');
      debugPrint('테스트 알림 발송 완료');
      debugPrint('발송 시간: ${DateTime.now().toString()}');
      debugPrint('알림 ID: 100');
      debugPrint('페이로드: alarm_test');
      debugPrint('======================================');

      return;
    } catch (e) {
      debugPrint('테스트 알림 발송 실패: $e');
      throw e;
    }
  }
}
