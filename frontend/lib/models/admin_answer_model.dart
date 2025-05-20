class Answer {
  final int? answerId;
  final String content;
  final String createdAt;

  Answer({
    this.answerId,
    required this.content,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerId: json['answerId'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answerId': answerId,
      'content': content,
      'createdAt': createdAt,
    };
  }
} 