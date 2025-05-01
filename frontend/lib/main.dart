import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'config/theme.dart';
// import 'screens/login/login_screen.dart';
import 'screens/login/login_main.dart';
import 'package:provider/provider.dart';
import 'providers/agree_provider.dart';
import 'providers/character_provider.dart';
import 'package:buds/screens/main_screen.dart';
import 'package:buds/services/notification_service.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:buds/screens/alarm/alarm_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 네비게이션 키 (전역에서 네비게이션 처리를 위함)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 알림을 통해 앱이 시작되었는지 여부를 저장
bool startedFromNotification = false;

// 초기 라우트 (알림에서 앱 시작 시 사용)
String? initialRoute;

// 알림 상태 저장 (백그라운드에서도 작동하도록 전역 함수로 선언)
@pragma('vm:entry-point')
Future<void> saveNotificationState() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('started_from_notification', true);
    // 알람 화면으로 이동하기 위한 초기 라우트 설정
    await prefs.setString('initial_route', '/alarm');
    debugPrint(
      '알림 상태 저장 완료: started_from_notification=true, initial_route=/alarm',
    );
  } catch (e) {
    debugPrint('알림 상태 저장 실패: $e');
  }
}

// 백그라운드 알림 이벤트 핸들러
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // 백그라운드에서 실행될 코드
  // 이 함수는 정적으로 접근 가능하고 NotificationService에서 참조됨
  debugPrint(
    '======================================\n'
    '백그라운드 알림 핸들러 실행됨\n'
    'ID: ${notificationResponse.id}, 페이로드: ${notificationResponse.payload}\n'
    '시간: ${DateTime.now().toString()}\n'
    '======================================',
  );

  try {
    // 알람 관련 알림인 경우 (ID 또는 페이로드로 확인)
    if (notificationResponse.id == 0 ||
        notificationResponse.id == 1 ||
        notificationResponse.id == 100 ||
        notificationResponse.payload == 'alarm' ||
        notificationResponse.payload == 'alarm_snooze' ||
        notificationResponse.payload == 'alarm_test') {
      // 알림을 통해 앱이 시작됨을 표시
      startedFromNotification = true;

      // 알림 상태를 SharedPreferences에 저장
      // 주의: 백그라운드 핸들러에서는 비동기 작업이 완료되기 전에 핸들러가 종료될 수 있음
      // 따라서 동기 방식으로 작업을 실행하도록 시도
      saveNotificationState(); // 비동기 함수이지만 여기서는 await 없이 호출

      debugPrint(
        '======================================\n'
        '백그라운드: 알람 관련 알림을 통해 앱이 시작됨\n'
        'ID: ${notificationResponse.id}, 페이로드: ${notificationResponse.payload}\n'
        '시간: ${DateTime.now().toString()}\n'
        '알람 화면으로 이동할 예정입니다.\n'
        '======================================',
      );
    } else {
      debugPrint(
        '======================================\n'
        '백그라운드: 일반 알림을 통해 앱이 시작됨\n'
        'ID: ${notificationResponse.id}\n'
        '시간: ${DateTime.now().toString()}\n'
        '======================================',
      );
    }
  } catch (e) {
    debugPrint('백그라운드 알림 처리 중 오류 발생: $e');
  }
}

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 상태 불러오기
  try {
    final prefs = await SharedPreferences.getInstance();
    startedFromNotification =
        prefs.getBool('started_from_notification') ?? false;
    initialRoute = prefs.getString('initial_route');

    if (startedFromNotification) {
      debugPrint('======================================');
      debugPrint('저장된 알림 상태 불러옴: 알림을 통해 시작됨');
      debugPrint('초기 라우트: $initialRoute');
      debugPrint('======================================');

      // 상태를 읽은 후 초기화
      await prefs.setBool('started_from_notification', false);
      await prefs.remove('initial_route');
    }
  } catch (e) {
    debugPrint('알림 상태 불러오기 실패: $e');
    // 오류 발생 시 기본 상태로 초기화
    startedFromNotification = false;
    initialRoute = null;
  }

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // 권한 요청 (Android만 사용)
  await NotificationService().requestPermission();

  // 앱 상태 로깅
  debugPrint('======================================');
  debugPrint('앱 시작됨: ${DateTime.now().toString()}');
  debugPrint('알림을 통한 시작 여부: $startedFromNotification');
  debugPrint('초기 라우트: $initialRoute');
  debugPrint('======================================');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(
          create:
              (context) => MyPageProvider(
                Provider.of<CharacterProvider>(context, listen: false),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 로깅 추가
    debugPrint(
      'MyApp build 함수 실행: initialRoute=$initialRoute, startedFromNotification=$startedFromNotification',
    );

    // 알림을 통해 시작된 경우 - initialRoute 기반 네비게이션
    if (startedFromNotification && initialRoute != null) {
      return MaterialApp(
        title: 'buds',
        navigatorKey: navigatorKey,
        theme: appTheme,
        initialRoute: initialRoute,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const MainScreen(),
          '/alarm':
              (context) => const AlarmScreen(
                title: '기상 시간입니다',
                message: '일어날 시간이에요!',
                notificationId: 0,
              ),
        },
      );
    }

    // 일반적인 앱 시작 - home 기반 네비게이션
    return MaterialApp(
      title: 'buds',
      navigatorKey: navigatorKey,
      theme: appTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/alarm':
            (context) => const AlarmScreen(
              title: '기상 시간입니다',
              message: '일어날 시간이에요!',
              notificationId: 0,
            ),
      },
      onGenerateRoute: (settings) {
        debugPrint('라우트 생성: ${settings.name}');
        if (settings.name == '/alarm') {
          return MaterialPageRoute(
            builder:
                (context) => const AlarmScreen(
                  title: '기상 시간입니다',
                  message: '일어날 시간이에요!',
                  notificationId: 0,
                ),
          );
        }
        return null;
      },
    );
  }
}
