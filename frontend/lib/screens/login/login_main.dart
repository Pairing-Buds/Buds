import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/login/widgets/index.dart';
import 'package:buds/screens/home/home_screen.dart';

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
              const SizedBox(height: 60),

              // 상단 타이틀 위젯
              const MainTitleWidget(),

              const SizedBox(height: 20),

              // 채팅 컨테이너 위젯
              const ChatContainer(),

              const SizedBox(height: 20),

              // 곰 캐릭터 클릭시 home_screen으로 이동
              GestureDetector(
                onTap: () {
                  // HomeScreen으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Image.asset(
                  'assets/images/newmarmet2.png',
                  scale: 2.5,
                ),
              ),

              const SizedBox(height: 20),

              // 시작하기 버튼 위젯
              const StartButton(),

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
