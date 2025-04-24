import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/login/widgets/login_form.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 뒤로 가기 버튼
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.brown[800]),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // 기존 내용
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 마멧 캐릭터 이미지
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/newmarmet.png'),
                    ),
                    const SizedBox(height: 16),

                    // 앱 타이틀
                    const Text(
                      'Buds',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 로그인 폼
                    const LoginForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
