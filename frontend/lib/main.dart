// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/screens/alarm/alarm_screen.dart';
import 'package:buds/screens/main_screen.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/services/notification_service.dart';
import 'package:buds/services/step_counter_manager.dart';
import 'config/theme.dart';
import 'providers/agree_provider.dart';
import 'providers/character_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_main.dart';
import 'screens/splash_screen.dart';

// import 'screens/login/login_screen.dart';
// import 'package:buds/providers/letter_provider.dart';

// 네비게이션 키 (전역에서 네비게이션 처리를 위함)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 앱이 알림을 통해 시작되었는지 여부 (전역 변수)
bool startedFromNotification = false;

// 초기 라우트 (알림으로 시작된 경우 '/'가 아닌 다른 경로로 시작)
String initialRoute = '/';

// 걸음 수 관리자 전역 인스턴스
final StepCounterManager stepCounterManager = StepCounterManager();

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
      // 알림 상태 저장 (SharedPreferences)
      // 이 코드는 백그라운드에서 실행되므로 SharedPreferences 인스턴스를 비동기적으로 얻어야 함
      SharedPreferences.getInstance().then((prefs) {
        // 알림을 통한 시작 상태 저장
        prefs.setBool('started_from_notification', true).then((_) {
          debugPrint('백그라운드: started_from_notification = true 저장됨');
        });

        // 초기 라우트 저장
        prefs.setString('initial_route', '/alarm').then((_) {
          debugPrint('백그라운드: initial_route = /alarm 저장됨');
        });
      });

      // 전역 변수에도 설정 (앱이 실행 중인 경우 사용됨)
      startedFromNotification = true;
      initialRoute = '/alarm';

      debugPrint('백그라운드: 알람 알림 상태 저장 완료');
    }
  } catch (e) {
    debugPrint('백그라운드 알림 처리 오류: $e');
  }
}

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드 시도 (오류 발생해도 앱이 종료되지 않도록 try-catch로 감싸기)
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('API URL: ${dotenv.env['API_URL']}');
  } catch (e) {
    debugPrint('환경 변수 로드 오류: $e');

    // 개발 환경인지 확인하고 처리
    const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;
    if (isDevelopment) {
      debugPrint('개발 환경에서 실행 중입니다. 환경 변수 파일을 생성해주세요.');
    } else {
      debugPrint('프로덕션 환경에서 실행 중입니다. 환경 변수가 설정되지 않았습니다.');
    }
  }

  // API 서비스 초기화 확인
  try {
    final apiService = DioApiService();
    await apiService.ensureInitialized();
    if (kDebugMode) {
      print('API 서비스 초기화 완료');
    }
  } catch (e) {
    if (kDebugMode) {
      print('API 서비스 초기화 실패: $e');
    }
  }

  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 걸음 수 측정 서비스 초기화
  try {
    await stepCounterManager.initialize();
    debugPrint('걸음 수 측정 서비스 초기화 성공');
  } catch (e) {
    debugPrint('걸음 수 측정 서비스 초기화 오류: $e');
  }

  // 알림 상태 초기화
  startedFromNotification = false;
  initialRoute = '/';

  // 네이티브 인텐트 확인 (안드로이드 전용)
  try {
    final intentData = await notificationService.checkInitialIntent();
    final bool isAlarm = intentData['is_alarm'] == true;
    final String action = intentData['action'] as String? ?? '';
    final int notificationId = intentData['notification_id'] as int? ?? -1;

    debugPrint(
      '인텐트 확인: action=$action, isAlarm=$isAlarm, notificationId=$notificationId',
    );

    // 알람 관련 인텐트인지 확인
    bool isAlarmRelated =
        isAlarm ||
        action == 'SELECT_NOTIFICATION' ||
        action == 'com.buds.app.ALARM_NOTIFICATION' ||
        notificationId == 0 ||
        notificationId == 1 ||
        notificationId == 100;

    if (isAlarmRelated) {
      startedFromNotification = true;
      initialRoute = '/alarm';
      debugPrint('인텐트 확인: 알람 인텐트로 앱이 시작되었습니다. 알람 화면으로 이동합니다.');

      // 알람 상태를 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('started_from_notification', true);
      await prefs.setString('initial_route', '/alarm');
    }
  } catch (e) {
    debugPrint('인텐트 확인 중 오류 발생: $e');
  }

  // SharedPreferences에서 알림 상태 불러오기 (인텐트에서 확인되지 않은 경우)
  if (!startedFromNotification) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationFlag =
          prefs.getBool('started_from_notification') ?? false;
      final savedRoute = prefs.getString('initial_route') ?? '/';

      debugPrint(
        'SharedPreferences에서 알림 상태 확인: notificationFlag=$notificationFlag, savedRoute=$savedRoute',
      );

      // 알림을 통해 시작되었고, 라우트가 알람인 경우에만 알람 화면으로 이동
      if (notificationFlag && savedRoute == '/alarm') {
        debugPrint('SharedPreferences: 알림을 통해 시작된 것으로 확인됨');
        startedFromNotification = true;
        initialRoute = '/alarm';
      }

      // 상태 확인 후 초기화 (중복 알람 화면 전환 방지)
      await prefs.setBool('started_from_notification', false);
      await prefs.remove('initial_route');
    } catch (e) {
      debugPrint('SharedPreferences에서 알림 상태 읽기 실패: $e');
    }
  }

  // 권한 요청 (Android만 사용) - 앱 시작 시 동시에 여러 권한을 요청하는 문제 해결을 위해 주석 처리
  // 대신 각 기능(걸음 수 측정, 알람)을 사용할 때 권한 요청하도록 함
  // await NotificationService().requestPermission();

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
        // ChangeNotifierProvider(
        //   create: (_) => LetterProvider(),
        //   child: const MyApp(),
        // ),
        ChangeNotifierProvider(
          create:
              (context) => MyPageProvider(
                Provider.of<CharacterProvider>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _onInitializationComplete() {
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로깅 추가
    debugPrint(
      'MyApp build 함수 실행: initialRoute=$initialRoute, startedFromNotification=$startedFromNotification',
    );

    // 초기화 중이면 스플래시 화면 표시
    if (!_isInitialized) {
      return MaterialApp(
        title: 'buds',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'), // 한국어
          Locale('en', 'US'), // 영어
        ],
        home: SplashScreen(
          onInitializationComplete: _onInitializationComplete,
        ),
      );
    }

    // 로그인 상태에 따른 초기 라우트 설정
    final authProvider = Provider.of<AuthProvider>(context);
    String appInitialRoute = initialRoute;

    // 알림으로 시작된 경우가 아니고, 로그인된 상태라면 메인 화면으로 이동
    if (!startedFromNotification && authProvider.isLoggedIn) {
      appInitialRoute = '/main';
    }

    return MaterialApp(
      title: 'buds',
      navigatorKey: navigatorKey,
      theme: appTheme,
      // 앱 상태에 따라 초기 라우트 결정
      initialRoute: appInitialRoute,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],
      routes: {
        '/': (context) => const LoginMainScreen(),
        '/main': (context) => const MainScreen(),
        '/alarm':
            (context) => const AlarmScreen(
              title: '기상 시간입니다',
              message: '좋은 아침입니다! 일어날 시간이에요.',
              notificationId: 0,
            ),
      },
    );
  }
}
