class DiaryCreateRequest {
  final String emotionDiary;
  final String activeDiary;
  final String date;

  DiaryCreateRequest({
    required this.emotionDiary,
    required this.activeDiary,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'emotion_diary': emotionDiary,
    'active_diary': activeDiary,
    'date': date,
  };
}
