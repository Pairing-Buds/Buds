// Flutter imports:
import 'package:flutter/material.dart';

class LetterEmptyState extends StatelessWidget {
  const LetterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('편지가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text(
            '익명의 편지를 보내보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
