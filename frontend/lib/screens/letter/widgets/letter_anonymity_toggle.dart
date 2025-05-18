// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';

class LetterAnonymityToggle extends StatelessWidget {
  final LetterProvider provider;

  const LetterAnonymityToggle({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Text(
            '보낼 편지',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              provider.toggleInterestMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: provider.isInterest ? AppColors.blue : AppColors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                provider.isInterest ? '관심' : '랜덤',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
