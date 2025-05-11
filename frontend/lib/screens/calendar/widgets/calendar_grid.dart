import 'package:flutter/material.dart';
import 'calendar_day.dart';
import 'package:buds/models/badge_model.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final Map<int, List<BadgeModel>> badgeMap;

  const CalendarGrid({
    Key? key,
    required this.currentMonth,
    required this.badgeMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOfWeek = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(CalendarDay(
        day: i,
        badges: badgeMap[i] ?? [],
        currentMonth: currentMonth,
      ));
    }

    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdays.map((day) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 32) / 7,
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // 날짜 그리드
          GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              mainAxisExtent: 95,
            ),
            childrenDelegate: SliverChildListDelegate(dayWidgets),
          ),
        ],
      ),
    );
  }
}
