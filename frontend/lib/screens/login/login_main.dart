// Flutter imports:
import 'package:flutter/material.dart';
// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/screens/login/widgets/index.dart';

/// 로그인 메인 화면
class LoginMainScreen extends StatelessWidget {
  const LoginMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        // LayoutBuilder로 화면 크기에 맞춰 위젯 크기와 여백 계산
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // 화면이 작을수록 요소를 더 줄여서 배치
            final titleScale = width < 360 ? 0.8 : 1.0;
            final imgRatio = width < 360 ? 0.28 : 0.33; // 전체 높이 대비 이미지 비율
            final topPad = height * 0.05;
            final middlePad = height * 0.02;
            final bottomPad = height * 0.03;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                children: [
                  SizedBox(height: topPad),

                  // 타이틀
                  Transform.scale(
                    scale: titleScale,
                    child: const MainTitleWidget(),
                  ),

                  SizedBox(height: middlePad),

                  // 채팅 버블
                  const ChatContainer(),

                  SizedBox(height: middlePad),

                  // 곰 캐릭터 – Flexible로 여유 공간에 맞춰 크기 조정
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 너무 클 경우만 축소
                      child: Image.asset(
                        'assets/images/newmarmetmain.png',
                        height: height * imgRatio, // 비율 기반 높이
                      ),
                    ),
                  ),

                  const StartButton(),

                  SizedBox(height: middlePad),

                  const LoginButton(),

                  SizedBox(height: bottomPad),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
