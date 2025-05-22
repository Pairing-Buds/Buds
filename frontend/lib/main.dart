// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/screens/activity/activity_screen.dart';
import 'package:buds/screens/alarm/alarm_screen.dart';
import 'package:buds/screens/login/onboarding_screen.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/screens/main_screen.dart';
import 'package:buds/screens/map/map_screen.dart';
import 'package:buds/screens/survey/survey_resurvey_screen.dart';
import 'package:buds/screens/survey/survey_retag_screen.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/services/notification_service.dart';
import 'package:buds/services/step_counter_manager.dart';
import 'config/theme.dart';
import 'providers/agree_provider.dart';
import 'providers/character_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_main.dart';
import 'screens/splash_screen.dart';
import 'providers/letter_provider.dart';
import 'package:buds/providers/admin_cs_provider.dart';

// 네비게이션 키 (전역에서 네비게이션 처리를 위함)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 앱이 알림을 통해 시작되었는지 여부 (전역 변수)
bool startedFromNotification = false;

// 초기 라우트 (알림으로 시작된 경우 '/'가 아닌 다른 경로로 시작)
String initialRoute = '/';

// 온보딩 완료 여부 확인용 전역 변수
bool isFirstLaunch = true; // 기본값은 true (첫 실행)

// 걸음 수 관리자 전역 인스턴스
final StepCounterManager stepCounterManager = StepCounterManager();

// 백그라운드 알림 이벤트 핸들러
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // 백그라운드에서 실행될 코드
  // 이 함수는 정적으로 접근 가능하고 NotificationService에서 참조됨
  

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
         
        });

        // 초기 라우트 저장
        prefs.setString('initial_route', '/alarm').then((_) {
         
        });
      });

      // 전역 변수에도 설정 (앱이 실행 중인 경우 사용됨)
      startedFromNotification = true;
      initialRoute = '/alarm';

      
    }
  } catch (e) {
    
  }
}

void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // API 서비스 초기화 확인
  try {
    final apiService = DioApiService();
    await apiService.ensureInitialized();
   
  } catch (e) {
   
  }

  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 걸음 수 측정 서비스 초기화
  try {
    await stepCounterManager.initialize();
    
  } catch (e) {
   
  }

  // 알림 상태 초기화
  startedFromNotification = false;
  initialRoute = '/';

  // 앱 첫 실행 여부 확인 (SharedPreferences 사용)
  try {
    final prefs = await SharedPreferences.getInstance();
    // 'completed_onboarding' 키가 없으면 true (첫 실행)
    isFirstLaunch = !(prefs.getBool('completed_onboarding') ?? false);
   

    // 알림으로 시작된 경우가 아니고, 첫 실행이라면 온보딩 화면으로 설정
    if (isFirstLaunch && !startedFromNotification) {
      initialRoute = '/onboarding';
    }
  } catch (e) {
    
  }

  // 네이티브 인텐트 확인 (안드로이드 전용)
  try {
    final intentData = await notificationService.checkInitialIntent();
    final bool isAlarm = intentData['is_alarm'] == true;
    final String action = intentData['action'] as String? ?? '';
    final int notificationId = intentData['notification_id'] as int? ?? -1;

   

    // 알람 관련 인텐트인지 확인
    bool isAlarmRelated =
        isAlarm ||
        action == 'SELECT_NOTIFICATION' ||
        action == 'com.buds.app.ALARM_NOTIFICATION' ||
        notificationId == 0 ||
        notificationId == 1 ||
        notificationId == 100;

    if (isAlarmRelated) {
      // 알람 시간이 유효한지 먼저 확인
      final prefs = await SharedPreferences.getInstance();
      final alarmScheduledDate = prefs.getString('alarm_scheduled_date');
      bool isValidAlarmTime = false;

      if (alarmScheduledDate != null) {
        final scheduledDate = DateTime.parse(alarmScheduledDate);
        final now = DateTime.now();

        // 알람 시간으로부터 5분 이내인지 확인
        final timeWindow = Duration(minutes: 5);
        final alarmTimeStart = scheduledDate;
        final alarmTimeEnd = scheduledDate.add(timeWindow);

        // 현재 시간이 알람 시간과 같거나 이후이고, 알람 시간 + 5분 이내인 경우에만 유효
        isValidAlarmTime =
            (now.isAtSameMomentAs(alarmTimeStart) ||
                now.isAfter(alarmTimeStart)) &&
            now.isBefore(alarmTimeEnd);

       
      }

      // 알람 시간이 유효할 때만 알람 화면으로 이동
      if (isValidAlarmTime) {
        startedFromNotification = true;
        initialRoute = '/alarm';
       

        // 알람 상태를 SharedPreferences에 저장
        await prefs.setBool('started_from_notification', true);
        await prefs.setString('initial_route', '/alarm');
      } else {
        startedFromNotification = false;
        initialRoute = '/';
      }
    }
  } catch (e) {
  }

  // SharedPreferences에서 알림 상태 불러오기 (인텐트에서 확인되지 않은 경우)
  if (!startedFromNotification) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationFlag =
          prefs.getBool('started_from_notification') ?? false;
      final savedRoute = prefs.getString('initial_route') ?? '/';
      final alarmScheduledDate = prefs.getString('alarm_scheduled_date');


      // 저장된 알람 시간이 있는지 확인하고, 현재 시간과 비교
      bool isValidAlarmTime = false;
      if (alarmScheduledDate != null) {
        final scheduledDate = DateTime.parse(alarmScheduledDate);
        final now = DateTime.now();

        // 알람 시간으로부터 5분 이내인지 확인
        final timeWindow = Duration(minutes: 5);
        final alarmTimeStart = scheduledDate;
        final alarmTimeEnd = scheduledDate.add(timeWindow);

        // 현재 시간이 알람 시간과 같거나 이후이고, 알람 시간 + 5분 이내인 경우에만 유효
        isValidAlarmTime =
            (now.isAtSameMomentAs(alarmTimeStart) ||
                now.isAfter(alarmTimeStart)) &&
            now.isBefore(alarmTimeEnd);

      
      }

      // 알림을 통해 시작되었고, 라우트가 알람인 경우에만 알람 화면으로 이동
      if (notificationFlag && savedRoute == '/alarm' && isValidAlarmTime) {
        startedFromNotification = true;
        initialRoute = '/alarm';
      } else {
        // 유효하지 않은 알람이면 홈 화면으로 이동하도록 설정
        if (notificationFlag && savedRoute == '/alarm' && !isValidAlarmTime) {
          startedFromNotification = false;
          initialRoute = '/';
        }
      }

      // 상태 확인 후 초기화 (중복 알람 화면 전환 방지)
      await prefs.setBool('started_from_notification', false);
      await prefs.remove('initial_route');
    } catch (e) {
    }
  }

  // 권한 요청 (Android만 사용) - 앱 시작 시 동시에 여러 권한을 요청하는 문제 해결을 위해 주석 처리
  // 대신 각 기능(걸음 수 측정, 알람)을 사용할 때 권한 요청하도록 함
  // await NotificationService().requestPermission();

  // 앱 상태 로깅
  
  // 앱이 비정상 종료되거나 메인 함수 실행이 완료될 때 실행될 클린업 코드
  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(
      resumeCallBack: () async {
       
        // StreamController 상태 리셋
        DioApiService.resetUnauthorizedController();
      },
      suspendingCallBack: () async {
       
        // 앱이 종료될 때 StreamController 닫기
        await DioApiService.closeUnauthorizedController();
      },
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(
          create:
              (context) => MyPageProvider(
                Provider.of<CharacterProvider>(context, listen: false),
              ),
        ),
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => LetterProvider()),
        ChangeNotifierProvider(create: (_) => AdminCSProvider()),
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
  bool _isUnauthorizedControllerClosed = true;

  @override
  void initState() {
    super.initState();
    // AuthProvider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.initialize(context).then((_) {
        _onInitializationComplete();
      });
    });
  }

  void _onInitializationComplete() {
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로깅 추가
   

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
        home: SplashScreen(onInitializationComplete: _onInitializationComplete),
      );
    }

    // 로그인 상태에 따른 초기 라우트 설정
    final authProvider = Provider.of<AuthProvider>(context);
    String appInitialRoute = initialRoute;

    // 알림으로 시작된 경우가 아니고, 로그인된 상태라면 메인 화면으로 이동
    if (!startedFromNotification && authProvider.isLoggedIn) {
      appInitialRoute = '/main';
    } // 알림으로 시작된 경우가 아니고, 첫 실행이라면 온보딩 화면으로 이동
    else if (isFirstLaunch && !startedFromNotification) {
      appInitialRoute = '/onboarding';
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
        '/activity': (context) => const ActivityScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/map': (context) => const MapScreen(),
        '/letter': (context) => const LetterScreen(),
        '/resurvey': (context) => const SurveyResurveyScreen(),
        '/retag': (context) => const SurveyRetagScreen(),
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

// 앱 생명주기 이벤트 핸들러
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
      default:
        break;
    }
  }
}
