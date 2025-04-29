import 'package:buds/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:buds/models/badge_model.dart';
import 'package:buds/screens/diary/diary_list_screen.dart';

class CalendarDay extends StatelessWidget {
  final int day;
  final List<BadgeModel> badges;
  final bool isHighlighted;

  const CalendarDay({
    Key? key,
    required this.day,
    required this.badges,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final thisDate = DateTime(today.year, today.month, day);

    final isToday = thisDate.year == today.year &&
        thisDate.month == today.month &&
        thisDate.day == today.day;

    final isPastOrToday = thisDate.isBefore(today) || isToday;

    return GestureDetector(
      onTap: () {
        final today = DateTime.now();
        final thisDate = DateTime(today.year, today.month, day); // 오늘 연, 월, 일로 구성
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryListScreen(selectedDate: thisDate),
          ),
        );
      },
    child:  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: isToday
                      ? Colors.white
                      : (isPastOrToday ? Colors.grey.shade700 : Colors.grey.shade400),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 45,
          child: badges.isNotEmpty
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: badges.map((badge) {
              return _buildBadgeImage(badge);
            }).toList(),
          )
              : const SizedBox(),
        ),
      ],
    ),
    );
  }
  Widget _buildBadgeImage(BadgeModel badge) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Image.asset(
        badge.imagePath,
        width: 45,
        height: 45,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}