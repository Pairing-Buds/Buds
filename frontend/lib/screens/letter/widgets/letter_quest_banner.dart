// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';

class LetterQuestBanner extends StatelessWidget {
  final bool isLandscape;

  const LetterQuestBanner({super.key, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: isLandscape ? 10 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.skyblue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              '오늘의 활동을 하고\n편지지를 모아봐요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 13),
            child: Image.asset(
              'assets/images/marmet_cutting_head.png',
              width: 80,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}
