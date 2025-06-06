// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';

/// 페이지 인디케이터 위젯
class PageIndicator extends StatelessWidget {
  final int currentPage;

  const PageIndicator({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6, // 캐릭터 개수 (6개)
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentPage == index ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
