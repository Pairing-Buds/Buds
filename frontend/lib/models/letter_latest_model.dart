class LatestLetterModel {
  final int letterId;

  LatestLetterModel({
    required this.letterId,
  });

  factory LatestLetterModel.fromJson(Map<String, dynamic> json) {
    return LatestLetterModel(
      letterId: json['letterId'] ?? 0, // ⭐ 기본값 0으로 안전 처리
    );
  }
}
