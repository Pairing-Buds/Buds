import 'package:flutter/material.dart';
import 'package:buds/widgets/common_button.dart';

// 홈 화면

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'home_screen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40), // 위아래 간격 조금 주고
            CommonButton(
              text: '제출하기', // 버튼 텍스트
              onPressed: () {
                // 버튼 눌렀을 때 실행할 코드
                print('제출하기 버튼 클릭됨');
              },
            ),
          ],
        ),
      ),
    );
  }
}