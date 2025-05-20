class UserModel {
  final int userId;
  final String userName;
  final String userEmail;
  final List<String>? tagTypes;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.tagTypes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String>? tags;
    if (json['tagTypes'] != null) {
      tags = List<String>.from(json['tagTypes']);
    }

    return UserModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      tagTypes: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'tagTypes': tagTypes,
    };
  }
} 