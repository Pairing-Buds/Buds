class LetterContentModel {
  final String content;

  LetterContentModel({
    required this.content,
});

  factory LetterContentModel.fromJson(Map<String, dynamic> json) {
    return LetterContentModel(
      content: json['content'],
    );
  }
}