// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/letter_provider.dart';

class LetterHeader extends StatelessWidget {
  const LetterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Row(
        children: [
          const Text(
            '편지 목록',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const Spacer(),
          // Provider로부터 편지 수 가져오기
          Consumer<LetterProvider>(
            builder: (context, provider, child) {
              return Text(
                '나의 편지 ${provider.letterCount}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              );
            },
          ),
        ],
      ),
    );
  }
}
