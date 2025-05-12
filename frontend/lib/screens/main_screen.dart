import 'package:flutter/material.dart';
import 'package:buds/screens/home/home_screen.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/screens/calendar/calendar_screen.dart';
import 'package:buds/screens/mypage/my_page_screen.dart';
import 'package:buds/widgets/bottom_nav_bar.dart';
import 'package:buds/providers/calendar_provider.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
    });
  }

  // 앱 종료 확인 다이얼로그
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('앱 종료'),
                content: const Text('앱을 종료하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('아니오'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 앱 종료
                      SystemNavigator.pop();
                    },
                    child: const Text('예'),
                  ),
                ],
              ),
        ) ??
        false;
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
