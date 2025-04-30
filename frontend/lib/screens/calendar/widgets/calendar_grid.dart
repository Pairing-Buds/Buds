import 'package:flutter/material.dart';
import 'calendar_day.dart';
import 'package:buds/models/badge_model.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({Key? key}) : super(key: key);

  Map<int, List<BadgeModel>> get mockBadges => {
    15: [BadgeModel(imagePath: 'assets/icons/badges/3000.png')],
    16: [BadgeModel(imagePath: 'assets/icons/badges/library.png')],
    18: [BadgeModel(imagePath: 'assets/icons/badges/wake.png')],
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime(2025, 4, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday % 7;

    final List<Widget> dayWidgets = [];

    // 빈칸 추가
    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    // 날짜 추가
    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(CalendarDay(
        day: i,
        badges: mockBadges[i] ?? [],
        isHighlighted: i == 18,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('일'),
              _DayLabel('월'),
              _DayLabel('화'),
              _DayLabel('수'),
              _DayLabel('목'),
              _DayLabel('금'),
              _DayLabel('토'),
            ],
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
              mainAxisExtent: 90,
            ),
            childrenDelegate: SliverChildListDelegate(dayWidgets),
          )
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40) / 7,
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}