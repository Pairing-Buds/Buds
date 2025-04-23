import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/login/widgets/index.dart';

/// 로그인 메인 화면
class LoginMainScreen extends StatelessWidget {
  const LoginMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // 상단 타이틀 위젯
              const MainTitleWidget(),

              const SizedBox(height: 40),

              // 채팅 컨테이너 위젯
              const ChatContainer(),

              const SizedBox(height: 30),

              // 곰 캐릭터 이미지
              Image.asset('assets/images/newmarmet2.png', scale: 2.5),

              const SizedBox(height: 0),

              // 시작하기 버튼 위젯
              StartButton(
                onPressed: () {
                  // 버튼 클릭 시 동작
                },
              ),

              const SizedBox(height: 20),

              // 로그인 버튼 위젯
              const LoginButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 채팅 버블 위젯
class ChatBubble extends StatelessWidget {
  final Color color;
  final String text;
  final bool isLeft;

  const ChatBubble({
    Key? key,
    required this.color,
    required this.text,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 8, backgroundColor: color),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
