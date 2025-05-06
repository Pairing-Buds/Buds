import 'package:buds/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buds/models/badge_model.dart';
import 'package:buds/services/calendar_service.dart';
import 'package:buds/screens/calendar/widgets/calendar_grid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime currentMonth = DateTime.now().toUtc().add(const Duration(hours: 9));
  late Future<Map<int, List<BadgeModel>>> badgeMapFuture;

  @override
  void initState() {
    super.initState();
    badgeMapFuture = fetchBadges();
  }

  Future<Map<int, List<BadgeModel>>> fetchBadges() {
    final formatted = DateFormat('yyyy-MM').format(currentMonth);
    return CalendarService.fetchMonthlyBadges(formatted);
  }

  Future<void> _showMonthPickerDialog() async {
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int selectedYear = currentMonth.year;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.primary,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                height: MediaQuery.of(context).size.height * 0.38,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => selectedYear--),
                          child: const Text('<', style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                        Text(
                          '$selectedYear년',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedYear++),
                          child: const Text('>', style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = selectedYear == currentMonth.year && month == currentMonth.month;

                          return TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(DateTime(selectedYear, month));
                            },
                            child: Text(
                              '$month',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        currentMonth = DateTime(selected.year, selected.month);
        badgeMapFuture = fetchBadges();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, List<BadgeModel>>>(
      future: badgeMapFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 0, 16),
                  child: Row(
                    children: [
                      Text(
                        '${currentMonth.month}월',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onPressed: _showMonthPickerDialog,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CalendarGrid(
                  currentMonth: currentMonth,
                  badgeMap: snapshot.data!,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
