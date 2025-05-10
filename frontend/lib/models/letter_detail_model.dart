class LetterDetailModel {
  final int letterId;
  final String senderName;
  // final String content;
  final String createdAt;
  final String status;
  final bool received;

  LetterDetailModel({
    required this.letterId,
    required this.senderName,
    // required this.content,
    required this.createdAt,
    required this.status,
    required this.received,
  });

  factory LetterDetailModel.fromJson(Map<String, dynamic> json) {
    return LetterDetailModel(
      letterId: json['letterId'],
      senderName: json['senderName'] ?? 'Unknown',
      // content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      received: json['received'] ?? false,
    );
  }
}
