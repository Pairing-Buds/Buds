import 'package:flutter/material.dart';
import 'package:buds/screens/login/login_screen.dart';
import 'package:buds/screens/login/widgets/chat_bubble.dart';
import 'package:buds/screens/login/agree_screen.dart';

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
          // 대화 버블 1 - 토끼
          ChatBubble(
            color: Colors.pink,
            text: '오늘은 무슨 좋은 일 있었어??',
            isLeft: true,
            iconPath: 'assets/icons/rabbiticon.png',
          ),
          const SizedBox(height: 10),

          // 대화 버블 2 - 여우
          ChatBubble(
            color: Colors.orange,
            text: '너무 많은 일이 있었어!',
            isLeft: false,
            iconPath: 'assets/icons/foxicon.png',
          ),
          const SizedBox(height: 10),

          // 대화 버블 3 - 토끼
          ChatBubble(
            color: Colors.pink,
            text: '어떤 일이 있었는데?',
            isLeft: true,
            iconPath: 'assets/icons/rabbiticon.png',
          ),
          const SizedBox(height: 10),

          // 대화 버블 4 - 개구리
          // ChatBubble(
          //   color: Colors.green,
          //   text: '나도 듣고 싶어!',
          //   isLeft: true,
          //   iconPath: 'assets/icons/frogicon.png',
          // ),
          // const SizedBox(height: 10),

          // 대화 버블 5 - 여우
          // ChatBubble(
          //   color: Colors.orange,
          //   text: '새로운 친구들을 많이 만났어요',
          //   isLeft: false,
          //   iconPath: 'assets/icons/foxicon.png',
          // ),
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
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgreeScreen()),
          );
        },
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
