class DiaryDay {
  final String date;
  final List<String> badgeList;
  final List<DiaryEntry> diaryList;

  DiaryDay({
    required this.date,
    required this.badgeList,
    required this.diaryList,
  });

  factory DiaryDay.fromJson(Map<String, dynamic> json) {
    final List<DiaryEntry> entries = [];
    final String date = json['date'];

    for (final item in (json['diaryList'] as List<dynamic>)) {
      final diaryNo = item['diaryNo'].toString();

      if (item['emotionDiary'] != null && item['emotionDiary'].toString().isNotEmpty) {
        entries.add(DiaryEntry(
          diaryNo: diaryNo,
          diaryType: 'EMOTION',
          content: item['emotionDiary'],
          date: date,
        ));
      }

      if (item['activeDiary'] != null && item['activeDiary'].toString().isNotEmpty) {
        entries.add(DiaryEntry(
          diaryNo: diaryNo,
          diaryType: 'ACTIVE',
          content: item['activeDiary'],
          date: date,
        ));
      }
    }

    return DiaryDay(
      date: date,
      badgeList: (json['badgeList'] as List<dynamic>)
          .map((b) => b['badge'] as String)
          .toList(),
      diaryList: entries,
    );
  }
}

class DiaryEntry {
  final String diaryNo;
  final String diaryType;
  final String content;
  final String date;

  DiaryEntry({
    required this.diaryNo,
    required this.diaryType,
    required this.content,
    required this.date,
  });

  factory DiaryEntry.empty() {
    return DiaryEntry(diaryNo: '0', diaryType: '', content: '', date: '');
  }
}
