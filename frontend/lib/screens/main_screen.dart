import 'package:flutter/material.dart';
import 'package:buds/screens/home/home_screen.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/screens/calendar/calendar_screen.dart';
import 'package:buds/screens/mypage/my_page_screen.dart';
import 'package:buds/widgets/bottom_nav_bar.dart'; // 하단 내브바 분리 파일

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
    const CalendarScreen(),
    const MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    child: Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    ),
    );
  }
}
