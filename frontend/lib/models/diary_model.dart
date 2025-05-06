class DiaryDay {
  final String date;
  final List<String> badgeList; // 실제 뱃지 이름들 (예: '3000')
  final List<DiaryEntry> diaryList;

  DiaryDay({required this.date, required this.badgeList, required this.diaryList});

  factory DiaryDay.fromJson(Map<String, dynamic> json) {
    return DiaryDay(
      date: json['date'],
      badgeList: (json['badgeList'] as List<dynamic>)
          .map((b) => b['badge'] as String)
          .toList(),
      diaryList: (json['diaryList'] as List<dynamic>)
          .map((d) => DiaryEntry.fromJson(d))
          .toList(),
    );
  }
}

class DiaryEntry {
  final String id; // ← ID 추가
  final String diaryType;
  final String content;
  final String date;

  DiaryEntry({
    required this.id,
    required this.diaryType,
    required this.content,
    required this.date,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'].toString(), // ← 응답에 id 있으면 넣기
      diaryType: json['diaryType'],
      content: json['content'],
      date: json['date'],
    );
  }
}

