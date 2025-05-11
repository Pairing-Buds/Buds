import 'package:flutter/material.dart';
import 'package:buds/screens/login/login_screen.dart';
import 'package:buds/screens/login/widgets/chat_bubble.dart';
import 'package:buds/screens/login/agree_screen.dart';

/// 상단 타이틀 위젯
class MainTitleWidget extends StatelessWidget {
  const MainTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth < 360 ? 15 : 18;
    final double logoFontSize = screenWidth < 360 ? 60 : 70;

    return Column(
      children: [
        // 상단 텍스트
        Text(
          '누군가와 대화 하는 즐거움',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        // const SizedBox(height: 10),
        // 로고 이미지와 앱 이름
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 새 이미지
            // Image.asset('assets/icons/buds_icon.png', width: 50, height: 50),
            // const SizedBox(width: 20),
            Text(
              'Buds',
              style: TextStyle(
                fontSize: logoFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 채팅 대화 컨테이너 위젯
class ChatContainer extends StatelessWidget {
  const ChatContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double spacing = screenWidth < 360 ? 5.0 : 8.0;

    // 채팅 컨테이너 주변에 패딩 추가
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 대화 버블 1 - 토끼
          ChatBubble(
            color: Colors.pink,
            text: '오늘은 무슨 좋은 일 있었어??',
            isLeft: true,
            iconPath: 'assets/icons/characters/rabbiticon.png',
          ),
          SizedBox(height: spacing),

          // 대화 버블 2 - 여우
          ChatBubble(
            color: Colors.orange,
            text: '너무 많은 일이 있었어!',
            isLeft: false,
            iconPath: 'assets/icons/characters/foxicon.png',
          ),
          SizedBox(height: spacing),

          // 대화 버블 3 - 토끼
          ChatBubble(
            color: Colors.pink,
            text: '어떤 일이 있었는데?',
            isLeft: true,
            iconPath: 'assets/icons/characters/rabbiticon.png',
          ),
        ],
      ),
    );
  }
}

/// 새롭게 시작하기 버튼 위젯
class StartButton extends StatelessWidget {
  const StartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth < 360 ? 220.0 : 250.0;
    final buttonHeight = screenWidth < 360 ? 50.0 : 55.0;

    return SizedBox(
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgreeScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: Size(buttonWidth, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          '새롭게 시작하기',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 12.0 : 14.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Text(
        '기존 계정으로 로그인',
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
