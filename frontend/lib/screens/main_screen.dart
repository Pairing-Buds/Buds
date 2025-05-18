// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/calendar_provider.dart';
import 'package:buds/screens/calendar/calendar_screen.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:buds/screens/home/home_screen.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/screens/mypage/my_page_screen.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/widgets/bottom_nav_bar.dart';
import 'package:buds/widgets/common_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LetterScreen(),
    CalendarScreen(),
    const MyPageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRedirectAnonymousUser();
      _setupUnauthorizedListener();
    });
  }

  @override
  void dispose() {
    // 구독 해제
    _unsubscribeFromUnauthorizedEvents();
    super.dispose();
  }

  // 401 에러 리스너 설정
  void _setupUnauthorizedListener() {
    try {
      // 401 에러 이벤트 구독
      unauthorizedController.stream.listen(
        (event) {
          // 401 에러 발생 시 중복 로그인 다이얼로그 표시
          if (event && mounted) {
            final apiService = DioApiService();
            apiService.showDuplicateLoginDialog(context);

            // 로그아웃 처리
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            authProvider.logout();
          }
        },
        onError: (e) {
          if (kDebugMode) {
            print('401 에러 이벤트 구독 오류: $e');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('401 에러 이벤트 구독 설정 오류: $e');
      }

      // 컨트롤러가 닫혔거나 에러가 발생한 경우에도 중복 로그인 처리
      if (DioApiService.isUnauthorizedControllerClosed && mounted) {
        final apiService = DioApiService();
        apiService.showDuplicateLoginDialog(context);

        // 로그아웃 처리
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();
      }
    }
  }

  // 구독 해제
  void _unsubscribeFromUnauthorizedEvents() {
    // 여기서는 StreamController가 전역 싱글턴이므로 실제로 구독 취소만 합니다
    // 전역 컨트롤러를 닫지는 않습니다
  }

  // 앱 종료 확인 다이얼로그
  Future<bool> _onWillPop() async {
    bool? shouldExit = await showDialog(
      context: context,
      builder:
          (context) => CommonDialog(
            title: '앱 종료',
            description: '앱을 종료하시겠습니까?',
            cancelText: '아니오',
            confirmText: '예',
            onCancel: () => Navigator.of(context).pop(false),
            onConfirm: () {
              SystemNavigator.pop();
            },
          ),
    );
    return shouldExit ?? false;
  }

  // 익명 사용자 체크 및 리디렉션
  void _checkAndRedirectAnonymousUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 내 정보 새로 가져오기
    authProvider
        .refreshUserData()
        .then((_) {
          if (kDebugMode) {
            print('메인 화면: 내 정보 조회 완료');
            print('메인 화면: 익명 사용자 여부: ${authProvider.isAnonymousUser}');
          }

          // 사용자가 익명인 경우 캐릭터 선택 화면으로 이동
          if (authProvider.isAnonymousUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CharacterSelectScreen(),
              ),
            );
          }
        })
        .catchError((e) {
          if (kDebugMode) {
            print('메인 화면: 내 정보 조회 실패: $e');
          }
          // 실패하더라도 계속 진행
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarProvider(),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: _screens[_selectedIndex],
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
