import 'package:flutter/material.dart';

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
            top: MediaQuery.of(context).size.height * 0.5, // 화면 높이의 45% 지점에 배치
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/newmarmet.png', // 주의: 폴더 이름 assets/image ❌ → assets/images ⭕ 로 수정했어요
                width: 200,
                height: 200,
              ),
            ),
          ),

          // 편지 아이콘
          Positioned(
            bottom: 80, // 화면 하단에서 40px 위
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
