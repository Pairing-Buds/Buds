import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class CalendarProvider extends ChangeNotifier {
  final Map<DateTime, List<BadgeModel>> _badgeMap = {
    DateTime(2025, 4, 16): [BadgeModel(imagePath: 'assets/icons/badges/WALK3000.png')],
    DateTime(2025, 4, 17): [BadgeModel(imagePath: 'assets/icons/badges/library.png')],
    DateTime(2025, 4, 18): [BadgeModel(imagePath: 'assets/icons/badges/wake.png')],
  };

  Map<DateTime, List<BadgeModel>> get badgeMap => _badgeMap;

  List<BadgeModel> getBadgesForDate(DateTime date) {
    return _badgeMap[DateTime(date.year, date.month, date.day)] ?? [];
  }
}
