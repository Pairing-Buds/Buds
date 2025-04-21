// 일기 모델

class Diary {
  final int id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Diary({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON 변환 메서드
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      imageUrl: json['image_url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'image_url': imageUrl,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
