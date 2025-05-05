import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/login/widgets/index.dart';
import 'package:buds/screens/home/home_screen.dart';
import 'package:buds/screens/chat/start_chatting_screen.dart';
import 'package:buds/screens/main_screen.dart';

/// 로그인 메인 화면
class LoginMainScreen extends StatelessWidget {
  const LoginMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // 기기 크기에 따른 스케일 계산
    final double titleScale = width < 360 ? 0.8 : 1.0;
    final double imageScale = width < 360 ? 3.0 : 2.5;

    // 세로 간격 조정
    final double topPadding = height * 0.05;
    final double middlePadding = height * 0.02;
    final double bottomPadding = height * 0.03;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        // 스크롤이 가능하도록 SingleChildScrollView 적용
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height - MediaQuery.of(context).padding.vertical,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: topPadding),

                  // 상단 타이틀 위젯 (반응형 스케일 적용)
                  Transform.scale(
                    scale: titleScale,
                    child: const MainTitleWidget(),
                  ),

                  SizedBox(height: middlePadding),

                  // 채팅 컨테이너 위젯
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartChattingScreen(),
                        ),
                      );
                    },
                    child: const ChatContainer(),
                  ),

                  SizedBox(height: middlePadding),

                  // 곰 캐릭터 이미지 (반응형 스케일 적용)
                  GestureDetector(
                    onTap: () {
                      // HomeScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/newmarmet2.png',
                      scale: imageScale,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // SizedBox(height: bottomPadding),

                  // 시작하기 버튼 위젯 (버튼은 크기 자동 조절)
                  const StartButton(),

                  SizedBox(height: middlePadding),

                  // 로그인 버튼 위젯
                  const LoginButton(),

                  SizedBox(height: bottomPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
