class CalendarBadge {
  final DateTime date;
  final List<String> badgeNames;

  CalendarBadge({
    required this.date,
    required this.badgeNames,
  });

  factory CalendarBadge.fromJson(Map<String, dynamic> json) {
    return CalendarBadge(
      date: DateTime.parse(json['date']),
      badgeNames: (json['badgeList'] as List<dynamic>)
          .map((badge) => badge['badge'] as String)
          .toList(),
    );
  }
}
