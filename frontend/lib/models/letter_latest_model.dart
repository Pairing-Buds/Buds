class LatestLetterModel {
  final int letterId;
  final String senderName;
  final String createdAt;
  final String content;
  final String status;
  final bool received;

  LatestLetterModel({
    required this.letterId,
    required this.senderName,
    required this.createdAt,
    required this.content,
    required this.status,
    required this.received,
  });
  factory LatestLetterModel.fromJson(Map<String, dynamic> json) {
    return LatestLetterModel(
      letterId: json['letterId'],
      senderName: json['senderName'] ?? 'Unknown',
      createdAt: json['createdAt'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      received: json['received'] ?? false,
    );
  }
}
