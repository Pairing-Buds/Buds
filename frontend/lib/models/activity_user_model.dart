class ActivityUserModel {
  final int userId;
  final String userEmail;
  final String birthDate;
  final String role;
  final bool isActive;
  final int letterCnt;
  final String userName;

  ActivityUserModel({
    required this.userId,
    required this.userEmail,
    required this.birthDate,
    required this.role,
    required this.isActive,
    required this.letterCnt,
    required this.userName,
  });

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory ActivityUserModel.fromJson(Map<String, dynamic> json) {
    return ActivityUserModel(
      userId: json['userId'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      birthDate: json['birthDate'] ?? '',
      role: json['role'] ?? '',
      isActive: json['isActive'] ?? false,
      letterCnt: json['letterCnt'] ?? 0,
      userName: json['userName'] ?? '',
    );
  }

  // Dart 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'birthDate': birthDate,
      'role': role,
      'isActive': isActive,
      'letterCnt': letterCnt,
      'userName': userName,
    };
  }
}
