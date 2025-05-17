// Flutter imports:
import 'package:flutter/material.dart';

class LetterAnswerHeader extends StatelessWidget {
  final String recipientName;
  final String postPosition;
  final String date;

  const LetterAnswerHeader({
    super.key,
    required this.recipientName,
    required this.postPosition,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 수신자 표시
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(
              flex: 5,
              child: Center(child: Text('$recipientName$postPosition')),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            date,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
