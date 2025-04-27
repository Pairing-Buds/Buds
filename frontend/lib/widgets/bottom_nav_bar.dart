import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/home.png', width: 28, height: 28),
          activeIcon: Image.asset('assets/icons/home_active.png', width: 28, height: 28),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/letter.png', width: 28, height: 28),
          activeIcon: Image.asset('assets/icons/letter_active.png', width: 28, height: 28),
          label: '편지',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/diary.png', width: 28, height: 28),
          activeIcon: Image.asset('assets/icons/diary_active.png', width: 28, height: 28),
          label: '일기',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/my.png', width: 28, height: 28),
          activeIcon: Image.asset('assets/icons/my_active.png', width: 28, height: 28),
          label: '마이',
        ),
      ],
    );
  }
}
