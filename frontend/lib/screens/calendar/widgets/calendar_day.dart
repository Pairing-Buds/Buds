import 'package:flutter/material.dart';
import 'package:buds/screens/diary/diary_list_screen.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/models/badge_model.dart';

class CalendarDay extends StatelessWidget {
  final int day;
  final List<BadgeModel> badges;
  final DateTime currentMonth;

  const CalendarDay({
    Key? key,
    required this.day,
    required this.badges,
    required this.currentMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final nowKST = DateTime.now().toUtc().add(const Duration(hours: 9));
    final today = DateTime(nowKST.year, nowKST.month, nowKST.day);
    final thisDate = DateTime(currentMonth.year, currentMonth.month, day);

    final isToday = thisDate == today;
    final isPastOrToday = thisDate.isBefore(today) || thisDate == today;
    final isSameMonth = thisDate.month == today.month && thisDate.year == today.year;

    final dateCircleSize = screenWidth * 0.085;

    final textColor = isToday
        ? Colors.white
        : (isPastOrToday ? Colors.grey.shade700 : Colors.grey.shade400);
    final effectiveColor = isSameMonth ? textColor : (thisDate.isBefore(today) ? Colors.grey.shade700 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryListScreen(selectedDate: thisDate),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: dateCircleSize + 4,
            child: Center(
              child: Container(
                width: dateCircleSize,
                height: dateCircleSize,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: screenHeight * 0.016,
                    color: effectiveColor,
                  ),
                ),
              ),
            ),
          ),
         // SizedBox(height: screenHeight * 0.005),
          SizedBox(
            height: screenHeight * 0.06,
            child: badges.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: badges.map((badge) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        badge.imagePath,
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeImage(BadgeModel badge, double size) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            badge.imagePath,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}