// Flutter imports:
import 'package:flutter/material.dart';

/// 푸터 텍스트 위젯
class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        '캐릭터는 마이페이지에서 변경 가능합니다!',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
