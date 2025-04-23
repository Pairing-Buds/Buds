import 'package:flutter/material.dart';
// import 'package:buds/screens/login/login_screen.dart';
import 'package:buds/screens/login/widgets/chat_bubble.dart';

/// 상단 타이틀 위젯
class MainTitleWidget extends StatelessWidget {
  const MainTitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 텍스트
        const Text(
          '누군가와 대화 하는 즐거움',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        // 로고 이미지와 앱 이름
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 새 이미지
            // Image.asset('assets/icons/buds_icon.png', width: 50, height: 50),
            // const SizedBox(width: 20),
            const Text(
              'Buds',
              style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
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
    return Container(
      width: 280,
      child: Column(
        children: [
          // 대화 버블 1
          ChatBubble(
            color: Colors.redAccent,
            text: '오늘은 무슨 좋은 일 있었어??',
            isLeft: true,
          ),
          const SizedBox(height: 12),
          // 대화 버블 2
          ChatBubble(color: Colors.orange, text: '너무 많은 일이 있었어', isLeft: false),
          const SizedBox(height: 12),
          // 대화 버블 3
          ChatBubble(color: Colors.redAccent, text: '저런...', isLeft: true),
        ],
      ),
    );
  }
}

/// 새롭게 시작하기 버튼 위젯
class StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(180, 55),
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
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginScreen()),
        // );
      },
      child: const Text(
        '기존 계정으로 로그인',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
