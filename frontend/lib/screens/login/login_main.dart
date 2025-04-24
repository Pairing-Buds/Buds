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
              const SizedBox(height: 80),

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
