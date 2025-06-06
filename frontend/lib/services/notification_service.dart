// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:buds/main.dart'; // navigatorKey와 saveNotificationState 함수 사용
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

  // 알림 인텐트 확인을 위한 메서드 채널
  static const notificationIntentChannel = MethodChannel(
    'com.buds.app/notification_intent',
  );

  /// 시작 인텐트 확인
  Future<Map<String, dynamic>> checkInitialIntent() async {
    try {
      final result = await notificationIntentChannel.invokeMethod(
        'getInitialIntent',
      );

      // Map<Object?, Object?> 타입을 Map<String, dynamic>으로 안전하게 변환
      Map<String, dynamic> intentData = {};
      if (result is Map) {
        result.forEach((key, value) {
          if (key is String) {
            intentData[key] = value;
          }
        });
      }

      final bool isAlarm = intentData['is_alarm'] == true;
      final int notificationId = intentData['notification_id'] as int? ?? -1;

      return intentData;
    } catch (e) {
      return {'is_alarm': false, 'notification_id': -1};
    }
  }

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    try {
      // timezone 초기화
      tz_data.initializeTimeZones();

      // 한국 시간대 설정
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      // 앱 시작 시 알림 상태 확인

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

        if (pendingNotificationIds.contains(999)) {
          await _flutterLocalNotificationsPlugin.cancel(999);
        }
      } catch (e) {}

      // 보류 중인 알림(미래에 예약된 알림)을 확인하여 처리
      await _checkPendingNotifications();

      // 배터리 최적화 설정 무시 요청
      _requestBatteryOptimizationDisable();

      // 앱이 알림을 통해 시작되었는지 확인 (알림을 탭했을 때만 알람 화면으로 이동)
      // 이 로직은 현재 구현되어 있지 않고, 알림을 통해 앱이 시작되면 notificationTapBackground에서 처리됨
    } catch (e) {}
  }

  /// 보류 중인 알림 확인 및 처리
  Future<void> _checkPendingNotifications() async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      final List<PendingNotificationRequest> pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      // 활성화된 알림 확인 (Android에서만 작동)
      try {
        final activeNotifications = await getActiveNotifications();

        if (activeNotifications.isNotEmpty) {
          // 알람 관련 알림이 있는지 확인 (ID 0 또는 1)
          bool hasAlarmNotification = activeNotifications.any(
            (notification) =>
                notification.id == 0 ||
                notification.id == 1 ||
                notification.id == 100,
          );

          // 알람 관련 알림이 있는 경우에만 알람 화면으로 이동
          if (hasAlarmNotification) {
            // 알림 상태를 저장 (앱이 꺼져있다가 재시작될 때를 대비)
            await _saveNotificationStateForRestart();

            Future.delayed(const Duration(seconds: 1), () {
              navigateToAlarmScreen();
            });
          }
        }
      } catch (e) {}
    } catch (e) {}
  }

  /// 알림 응답 처리
  void _onNotificationResponse(NotificationResponse response) {
    // 알람 관련 알림인 경우 (ID 또는 페이로드로 확인)
    if (_isAlarmNotification(response.id ?? 0, response.payload ?? '')) {
      // 알림 상태를 SharedPreferences에 저장 (재시작 시 사용)
      _saveNotificationStateForRestart().then((_) {
        // 전역 변수에도 직접 설정
        startedFromNotification = true;
        initialRoute = '/alarm';

        // 알람 화면으로 즉시 이동
        navigateToAlarmScreen();
      });
    }
  }

  /// 알람 관련 알림인지 확인
  bool _isAlarmNotification(int id, String payload) {
    return id == 0 ||
        id == 1 ||
        id == 100 ||
        payload == 'alarm' ||
        payload == 'alarm_snooze' ||
        payload == 'alarm_test';
  }

  /// 앱 재시작을 위한 알림 상태 저장
  Future<void> _saveNotificationStateForRestart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('started_from_notification', true);
      await prefs.setString('initial_route', '/alarm');

      // 저장 시간도 함께 기록
      await prefs.setString('notification_saved_at', DateTime.now().toString());
      return Future.value();
    } catch (e) {
      return Future.value();
    }
  }

  /// 알람 화면으로 이동
  void navigateToAlarmScreen() {
    // 알람 시간이 유효한지 먼저 확인
    _checkAlarmTimeValidity().then((isValid) {
      if (!isValid) {
        // 홈 화면으로 리다이렉션
        Future.microtask(() {
          if (navigatorKey.currentState != null) {
            try {
              // 현재 알람 화면이면 홈으로 돌아가기
              final currentRoute =
                  ModalRoute.of(
                    navigatorKey.currentState!.context,
                  )?.settings.name;
              if (currentRoute == '/alarm') {
                navigatorKey.currentState!.pushReplacementNamed('/');
              }
            } catch (e) {}
          }
        });

        return;
      }

      // 전역 상태 설정 (메인.dart에서 참조)
      startedFromNotification = true;
      initialRoute = '/alarm';

      // 메인 스레드에서 실행하여 UI 업데이트 보장
      Future.microtask(() {
        if (navigatorKey.currentState != null) {
          try {
            // 기존 라우트 체크 (이미 알람 화면이 있으면 스택에서 제거 후 새로 추가)
            final currentRoute =
                ModalRoute.of(
                  navigatorKey.currentState!.context,
                )?.settings.name;

            if (currentRoute == '/alarm') {
              // 이미 알람 화면에 있으면 새로 고침
              navigatorKey.currentState!.pushReplacementNamed('/alarm');
            } else {
              // 알람 화면으로 이동
              navigatorKey.currentState!.pushNamed('/alarm');
            }
          } catch (e) {
            // 오류 발생 시 1초 후 다시 시도
            Future.delayed(const Duration(seconds: 1), () {
              try {
                if (navigatorKey.currentState != null) {
                  navigatorKey.currentState!.pushNamed('/alarm');
                }
              } catch (e) {}
            });
          }
        }
      });
    });
  }

  /// 알람 시간이 유효한지 확인
  Future<bool> _checkAlarmTimeValidity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmScheduledDate = prefs.getString('alarm_scheduled_date');

      if (alarmScheduledDate == null) {
        return false;
      }

      final scheduledDate = DateTime.parse(alarmScheduledDate);
      final now = DateTime.now();

      // 알람 시간으로부터 5분 이내인지 확인
      final timeWindow = Duration(minutes: 5);
      final alarmTimeStart = scheduledDate;
      final alarmTimeEnd = scheduledDate.add(timeWindow);

      // 현재 시간이 알람 시간과 같거나 이후이고, 알람 시간 + 5분 이내인 경우에만 유효
      final isValidAlarmTime =
          (now.isAtSameMomentAs(alarmTimeStart) ||
              now.isAfter(alarmTimeStart)) &&
          now.isBefore(alarmTimeEnd);

      // 알람 시간이 유효하지 않은 경우(5분 이상 지난 경우) 알람 데이터 삭제
      if (!isValidAlarmTime && now.isAfter(alarmTimeEnd)) {
        await _clearExpiredAlarmData();
      }

      return isValidAlarmTime;
    } catch (e) {
      return false;
    }
  }

  /// 만료된 알람 데이터 초기화
  Future<void> _clearExpiredAlarmData() async {
    try {
      // 알람 관련 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('alarm_hour');
      await prefs.remove('alarm_minute');
      await prefs.remove('alarm_scheduled_date');
      await prefs.remove('alarm_scheduled_at');

      // 알림 상태 초기화
      await prefs.setBool('started_from_notification', false);
      await prefs.remove('initial_route');

      // 진행 중인 알림 취소
      await _flutterLocalNotificationsPlugin.cancel(0); // 기본 알람 ID
      await _flutterLocalNotificationsPlugin.cancel(1); // 스누즈 알람 ID

      // 전역 상태 초기화
      startedFromNotification = false;
      initialRoute = '/';
    } catch (e) {}
  }

  /// 알람 상태 활성화
  void _activateAlarm() {
    // 이 메서드는 현재 사용되지 않습니다만 향후 확장성을 위해 유지
  }

  /// 알람 상태 비활성화
  Future<void> deactivateAlarm() async {
    // 알람 상태를 완전히 초기화
    try {
      // 전역 변수 초기화
      startedFromNotification = false;
      initialRoute = '/'; // null 대신 기본 루트 사용

      // SharedPreferences에서 값 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('started_from_notification', false);
      await prefs.remove('initial_route');

      // 알림 플래그 파일도 삭제
      try {
        final directory = await getApplicationDocumentsDirectory();
        final flagFile = File('${directory.path}/alarm_notification.flag');
        if (await flagFile.exists()) {
          await flagFile.delete();
        }
      } catch (e) {}
    } catch (e) {}
  }

  /// 알람 관련 알림 채널 설정 (일반 알림만 사용)
  Future<void> _setupAlarmNotificationChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          'alarm_channel_standard',
          '알람 채널 (표준)',
          description: '기본 알람 알림을 위한 채널입니다',
          importance: Importance.high,
          showBadge: true,
          playSound: false, // 소리 비활성화
          enableVibration: true, // 진동 활성화
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]), // 진동 패턴 설정
        ),
      );
    }
  }

  /// 알람 화면으로 바로 이동
  void showAlarmScreen() {
    navigateToAlarmScreen();
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // 알림 권한 요청
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();

        // 정확한 알람 설정 권한 요청 (Android 12+)
        bool canScheduleExactAlarms = await _checkAndRequestExactAlarms();

        return granted ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 정확한 알람 설정 권한 확인 및 요청
  Future<bool> _checkAndRequestExactAlarms() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // Android 12 이상에서만 작동
        bool? canScheduleExactAlarms =
            await androidImplementation.canScheduleExactNotifications();

        if (canScheduleExactAlarms == false) {
          // 설정 화면으로 이동하여 권한 요청
          await androidImplementation.requestExactAlarmsPermission();
          // 권한 상태 다시 확인
          canScheduleExactAlarms =
              await androidImplementation.canScheduleExactNotifications();
        }

        return canScheduleExactAlarms ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 배터리 최적화 설정 무시 요청
  Future<bool> _requestBatteryOptimizationDisable() async {
    try {
      // 배터리 최적화 예외 요청
      final bool result = await platform.invokeMethod(
        'requestBatteryOptimization',
      );
      if (result) {
        // 3초 대기 후 상태 다시 확인
        await Future.delayed(const Duration(seconds: 3));
        final bool status = await platform.invokeMethod(
          'isBatteryOptimizationDisabled',
        );
        return status;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 테스트 알림 발송
  Future<void> sendTestNotification() async {
    try {
      // 안드로이드 전용 설정: 인텐트 추가
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_channel_standard',
        '알람 채널 (표준)',
        channelDescription: '기본 알람 알림을 위한 채널입니다',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        // 알림을 탭했을 때 from_notification 플래그가 전달되도록 설정
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'dismiss',
            '알람 끄기',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        100, // 테스트 알림 ID
        '테스트 알람',
        '테스트 알람 메시지입니다. 탭하여 알람 화면으로 이동하세요.',
        notificationDetails,
        payload: 'alarm_test',
      );

      // 알림 상태를 미리 저장
      await _saveNotificationStateForRestart();
    } catch (e) {}
  }

  /// 인텐트를 사용한 테스트 알람 시작
  Future<void> testAlarmIntent() async {
    try {
      // 안드로이드에서만 작동하는 플랫폼 채널 사용
      const platform = MethodChannel('com.buds.app/notification_intent');

      // 네이티브 코드에서 알람 인텐트 테스트 호출
      final result = await platform.invokeMethod('testAlarmIntent');
    } catch (e) {}
  }

  /// 기상 알람 예약
  Future<void> scheduleWakeUpAlarm(TimeOfDay time) async {
    // 이전 알람 취소
    await cancelAllAlarms();

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel_standard',
      '알람 채널 (표준)',
      channelDescription: '기본 알람 알림을 위한 채널입니다',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      autoCancel: false,
      ongoing: true,
      showWhen: true,
      enableLights: true,
      playSound: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'dismiss',
          '알람 끄기',
          cancelNotification: true,
          showsUserInterface: true,
        ),
      ],
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
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

      // 알람 시간 정보 로그 출력
      final difference = scheduledDateTime.difference(
        tz.TZDateTime.now(tz.local),
      );
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      // SharedPreferences에 알람 시간 저장
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('alarm_hour', time.hour);
        await prefs.setInt('alarm_minute', time.minute);
        await prefs.setString(
          'alarm_scheduled_date',
          scheduledDateTime.toString(),
        );
        await prefs.setString('alarm_scheduled_at', DateTime.now().toString());
      } catch (e) {}

      // 알림 상태를 미리 저장 (앱이 꺼져있다가 재시작될 때를 대비)
      await _saveNotificationStateForRestart();

      // 알림 예약
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID
        '기상 시간입니다',
        '일어날 시간이에요! 탭하여 알람 화면으로 이동하세요.',
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'alarm', // 알림 페이로드
      );

      return;
    } catch (e) {
      rethrow;
    }
  }

  /// 5분 후 다시 알림 (스누즈)
  Future<void> snoozeAlarm() async {
    try {
      // 현재 시간에서 5분 후 알림 예약
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDateTime = now.add(const Duration(minutes: 5));

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_channel_standard',
        '알람 채널 (표준)',
        channelDescription: '다시 울리는 알람 알림입니다',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        // 알림을 탭했을 때 from_notification 플래그가 전달되도록 설정
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'dismiss',
            '알람 끄기',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // 알림 상태를 미리 저장
      await _saveNotificationStateForRestart();

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // 스누즈용 ID
        '기상 알람 (다시 알림)',
        '5분이 지났습니다. 일어날 시간이에요! 탭하여 알람 화면으로 이동하세요.',
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'alarm_snooze',
      );
    } catch (e) {}
  }

  /// 모든 알람 알림 취소
  Future<void> cancelAllAlarms() async {
    try {
      // 기본 알람 (ID: 0)
      await _flutterLocalNotificationsPlugin.cancel(0);
      // 스누즈 알람 (ID: 1)
      await _flutterLocalNotificationsPlugin.cancel(1);
      // 테스트 알람 (ID: 999)
      await _flutterLocalNotificationsPlugin.cancel(999);
      // 다른 테스트 알람 (ID: 100)
      await _flutterLocalNotificationsPlugin.cancel(100);

      // SharedPreferences에서 알람 관련 데이터 삭제
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('alarm_hour');
        await prefs.remove('alarm_minute');
        await prefs.remove('alarm_scheduled_date');
        await prefs.remove('alarm_scheduled_at');
      } catch (e) {}
    } catch (e) {}
  }

  /// 활성화된 알림 가져오기
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      final List<ActiveNotification> activeNotifications =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.getActiveNotifications() ??
          [];
      return activeNotifications;
    } catch (e) {
      return [];
    }
  }

  /// 알람에 필요한 모든 권한 확인 및 요청
  Future<Map<String, bool>> checkAndRequestAllPermissions() async {
    try {
      // 1. 알림 권한 확인 및 요청
      final bool notificationPermission = await requestPermission();

      // 2. 정확한 알람 권한 확인 및 요청
      final bool exactAlarmPermission = await _checkAndRequestExactAlarms();

      // 3. 배터리 최적화 예외 요청
      final bool batteryOptimization =
          await _requestBatteryOptimizationDisable();

      return {
        'notification': notificationPermission,
        'exactAlarm': exactAlarmPermission,
        'batteryOptimization': batteryOptimization,
      };
    } catch (e) {
      return {
        'notification': false,
        'exactAlarm': false,
        'batteryOptimization': false,
      };
    }
  }
}
