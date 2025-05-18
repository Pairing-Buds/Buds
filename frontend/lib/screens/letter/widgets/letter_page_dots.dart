// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';

class LetterPageDot extends StatelessWidget {
  final int index;
  final int totalCount;
  final int currentIndex;
  final VoidCallback onTap;

  const LetterPageDot({
    super.key,
    required this.index,
    required this.totalCount,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }
}

List<Widget> buildLetterPageDots(LetterProvider provider) {
  if (provider.letterPage == null) return [];

  return List.generate(provider.letterPage!.letters.length, (index) {
    return LetterPageDot(
      index: index,
      totalCount: provider.letterPage!.letters.length,
      currentIndex: provider.currentLetterIndex,
      onTap: () {
        provider.setCurrentLetterIndex(index);
      },
    );
  });
}
