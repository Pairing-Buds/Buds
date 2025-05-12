class ActivityQuoteModel {
  final int quoteId;
  final String sentence;
  final String speaker;

  ActivityQuoteModel({
    required this.quoteId,
    required this.sentence,
    required this.speaker,
});

  factory ActivityQuoteModel.fromJson(Map<String, dynamic> json) {
    final resMsg = json['resMsg'] ?? {};
    return ActivityQuoteModel(
      quoteId: resMsg['quoteId'] ?? 0,
      sentence: resMsg['sentence'] ?? '알 수 없음',
      speaker: resMsg['speaker'] ?? '미상',
    );
  }
}