import 'package:flutter/material.dart';
import 'package:buds/models/badge_model.dart';
import 'package:buds/screens/calendar/widgets/calendar_day.dart';
import 'package:buds/services/calendar_service.dart'; // API 호출 클래스
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime currentDate = DateTime.utc(2025, 4, 1).add(const Duration(hours: 9));
  final List<String> weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  late Future<Map<int, List<BadgeModel>>> badgeMapFuture;

  @override
  void initState() {
    super.initState();
    final formattedDate = DateFormat('yyyy-MM').format(currentDate);
    badgeMapFuture = CalendarService.fetchMonthlyBadges(formattedDate, 1); // userId는 실제 로그인값으로
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, List<BadgeModel>>>(
      future: badgeMapFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final badgeMap = snapshot.data!;
        final daysInMonth = DateUtils.getDaysInMonth(currentDate.year, currentDate.month);
        final firstDayOfWeek = DateTime(currentDate.year, currentDate.month, 1).weekday % 7;

        final List<Widget> dayWidgets = [];

        for (int i = 0; i < firstDayOfWeek; i++) {
          dayWidgets.add(const SizedBox.shrink());
        }

        for (int i = 1; i <= daysInMonth; i++) {
          dayWidgets.add(CalendarDay(
            day: i,
            badges: badgeMap[i] ?? [],
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
                        '${currentDate.month}월',
                        style: const TextStyle(fontSize: 24),
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
      },
    );
  }
}
