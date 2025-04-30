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

// 네비게이션 키 (전역에서 네비게이션 처리를 위함)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 알림을 통해 앱이 시작되었는지 여부를 저장
bool startedFromNotification = false;

// 백그라운드 알림 이벤트 핸들러
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // 백그라운드에서 실행될 코드
  // 이 함수는 정적으로 접근 가능하고 NotificationService에서 참조됨

  // 알람 관련 알림인 경우 (ID 또는 페이로드로 확인)
  if (notificationResponse.id == 0 ||
      notificationResponse.id == 1 ||
      notificationResponse.payload == 'alarm' ||
      notificationResponse.payload == 'alarm_snooze') {
    // 알림을 통해 앱이 시작됨을 표시
    startedFromNotification = true;
    debugPrint(
      '======================================\n'
      '백그라운드: 알림을 통해 앱이 시작됨\n'
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
}

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // 권한 요청 (Android만 사용)
  await NotificationService().requestPermission();

  // 앱 상태 로깅
  debugPrint('======================================');
  debugPrint('앱 시작됨: ${DateTime.now().toString()}');
  debugPrint('알림을 통한 시작 여부: $startedFromNotification');
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
    // 알림을 통해 앱이 시작된 경우 알람 화면으로 이동
    if (startedFromNotification) {
      debugPrint('======================================');
      debugPrint('알림을 통해 앱이 시작되어 알람 화면으로 이동합니다.');
      debugPrint('시간: ${DateTime.now().toString()}');

      // 약간의 지연 후 알람 화면으로 이동 (UI 초기화를 위해)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed('/alarm');
          debugPrint('알림 후 알람 화면으로 이동 완료');
          debugPrint('시간: ${DateTime.now().toString()}');
          // 플래그 초기화
          startedFromNotification = false;
          debugPrint('======================================');
        } else {
          debugPrint('알림 후 알람 화면으로 이동 실패: NavigatorState가 null');
          debugPrint('시간: ${DateTime.now().toString()}');
          debugPrint('======================================');

          // 3초 후 다시 시도
          Future.delayed(const Duration(seconds: 3), () {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushNamed('/alarm');
              debugPrint('알림 후 알람 화면으로 이동 재시도 완료');
              // 플래그 초기화
              startedFromNotification = false;
            }
          });
        }
      });
    } else {
      debugPrint('======================================');
      debugPrint('일반 실행: 알람 화면으로 자동 이동하지 않습니다.');
      debugPrint('시간: ${DateTime.now().toString()}');
      debugPrint('======================================');
    }

    return MaterialApp(
      title: 'buds',
      navigatorKey: navigatorKey, // 전역 네비게이션 키 설정
      theme: appTheme,
      home: const MainScreen(),
      //home: const LoginMainScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/alarm':
            (context) => const AlarmScreen(
              title: '기상 시간입니다',
              message: '일어날 시간이에요!',
              notificationId: 0,
            ),
      },
    );
  }
}
