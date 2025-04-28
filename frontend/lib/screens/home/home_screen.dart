import 'package:flutter/material.dart';
import 'package:buds/screens/home/widget/shell_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Positioned.fill(
            child: Image.asset(
              'assets/images/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 태양 아이콘
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // TODO: 태양 아이콘 눌렀을 때
              },
              child: Image.asset(
                'assets/icons/sun.png',
                width: 120,
                height: 120,
              ),
            ),
          ),

          // 음악 on/off 아이콘
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // TODO: 배경음악 끄는 기능 추가
              },
              child: Image.asset(
                'assets/icons/music_active.png',
                width: 40,
                height: 40,
              ),
            ),
          ),

          // 캐릭터 이미지
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.width * 0.5 - 100, // 화면 가로 가운데에 맞추기 (width 200 고려)
            child: Image.asset(
              'assets/images/newmarmet.png',
              width: 200,
              height: 200,
            ),
          ),

          // 조개 아이콘 클릭시 shell_screen으로 이동
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.65, // 캐릭터보다 살짝 아래
            left: 40, // 왼쪽에서 40px 띄움
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShellScreen()),
                );
              },
              child: Image.asset(
                'assets/icons/shell.png',
                width: 80,
                height: 80,
              ),
            ),
          ),


          // 편지 아이콘
          Positioned(
            bottom: 80,
            left: 190,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: 편지 아이콘 눌렀을 때 처리
                },
                child: Image.asset(
                  'assets/icons/bottle_letter.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
