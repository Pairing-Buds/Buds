import 'package:flutter/material.dart';
import '../../../models/badge_model.dart';

class CalendarBadge extends StatelessWidget {
  final List<BadgeModel> badges;

  const CalendarBadge({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox(height: 36);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: badges.map((badge) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Image.asset(
            badge.imagePath,
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        );
      }).toList(),
    );
  }
}
