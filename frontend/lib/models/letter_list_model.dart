class LetterModel {
  final int userId;
  final String userName;
  final String lastLetterDate;
  final String lastLetterStatus;
  final bool received;

  LetterModel({
    required this.userId,
    required this.userName,
    required this.lastLetterDate,
    required this.lastLetterStatus,
    required this.received,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      userId: json['userId'],
      userName: json['userName'],
      lastLetterDate: json['lastLetterDate'],
      lastLetterStatus: json['lastLetterStatus'],
      received: json['received'],
    );
  }
}