class LetterModel {
  final int userId;
  final String userName;
  final String lastLetterDate;
  final String lastLetterStatus;
  final bool received;

  // 특정 사용자와 주고 받은 편지
  final int letterId;
  final String senderName;
  final String createdAt;
  final String status; // read/unread

  // 특정 사용자와 주고 받은 편지 개별 조회
  final String content;

  LetterModel({
    required this.userId,
    required this.userName,
    required this.lastLetterDate,
    required this.lastLetterStatus,
    required this.received,

    required this.letterId,
    required this.senderName,
    required this.createdAt,
    required this.status,

    required this.content,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      userId: json['userId'],
      userName: json['userName'],
      lastLetterDate: json['lastLetterDate'],
      lastLetterStatus: json['lastLetterStatus'],
      received: json['received'],

      letterId: json['letterId'],
      senderName: json['senderName'] ?? 'Unknown',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? 'UNKNOWN',

      content: json['content'] ?? '',
    );
  }
}