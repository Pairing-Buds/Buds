// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/screens/activity/shell_screen.dart';
import 'package:buds/screens/chat/chat_detail_screen.dart';
import 'package:buds/screens/home/widgets/speech_bubble.dart';
import 'package:buds/screens/home/latest_letter_screen.dart';
import 'package:buds/screens/survey/survey_screen.dart';
import 'package:buds/screens/home/test.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/main_bg.png',
                fit: BoxFit.cover,
              ),
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
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: Image.asset(
                'assets/icons/survey_icon.png',
                width: 40,
                height: 40,
              ),
            ),
          ),

          // 캐릭터 이미지
          Positioned(
            top: MediaQuery.of(context).size.height * 0.435,
            left: MediaQuery.of(context).size.width * 0.5 - 100,
            child: Image.asset(
              'assets/icons/characters/newmarmet.png',
              width: 200,
              height: 200,
            ),
          ),

          // 말풍선 위젯
          const SpeechBubbleScreen(),

          // 조개 아이콘
          Positioned(
            top: MediaQuery.of(context).size.height * 0.575,
            left: 40,
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
            bottom: MediaQuery.of(context).size.height * 0.15 - 100,
            left: 190,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LastLetterScreen(),
                    ),
                  );
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
