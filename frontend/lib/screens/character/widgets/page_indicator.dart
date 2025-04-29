import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';

/// 페이지 인디케이터 위젯
class PageIndicator extends StatelessWidget {
  final int currentPage;

  const PageIndicator({Key? key, required this.currentPage}) : super(key: key);

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
