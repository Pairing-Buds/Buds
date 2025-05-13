class TagRecUserModel {
  final int userId;
  final String userName;
  final List<String> tagTypes;

  TagRecUserModel({
    required this.userId,
    required this.userName,
    required this.tagTypes,
  });

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory TagRecUserModel.fromJson(Map<String, dynamic> json) {
    return TagRecUserModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      tagTypes: List<String>.from(json['tagTypes'] ?? []),
    );
  }

  // Dart 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {'userId': userId, 'userName': userName, 'tagTypes': tagTypes};
  }
}
