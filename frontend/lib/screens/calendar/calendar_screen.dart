import 'package:flutter/material.dart';
import 'package:buds/models/badge_model.dart';
import 'package:buds/screens/calendar/widgets/calendar_day.dart';

class CalendarScreen extends StatelessWidget {
  final DateTime currentDate = DateTime(2025, 4, 1);

  CalendarScreen({super.key});

  final List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  final Map<int, List<BadgeModel>> mockBadges = {
    15: [BadgeModel(imagePath: 'assets/icons/badges/3000.png')],
    16: [BadgeModel(imagePath: 'assets/icons/badges/library.png')],
    18: [BadgeModel(imagePath: 'assets/icons/badges/wake.png')],
  };

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentDate.year, currentDate.month);
    final firstDayOfWeek = DateTime(currentDate.year, currentDate.month, 1).weekday % 7;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(CalendarDay(
        day: i,
        badges: mockBadges[i] ?? [],
        isHighlighted: i == 18,
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    '4월',
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekdays.map((day) {
                  return SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.custom(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  mainAxisExtent: 95,
                ),
                childrenDelegate: SliverChildListDelegate(dayWidgets),
              ),
            ),
          ],
        ),
      ),
    );
  }
}