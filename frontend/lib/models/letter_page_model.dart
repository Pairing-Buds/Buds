import 'package:buds/models/letter_detail_model.dart';

class LetterPageModel {
  final int opponentId; // 상대방 사용자 ID
  final String opponentName; // 상대방 사용자 이름
  final int currentPage; // 현재 페이지
  final int totalPages; // 전체 페이지 수
  final List<LetterDetailModel> letters; // 편지 리스트

  LetterPageModel({
    required this.opponentId,
    required this.opponentName,
    required this.currentPage,
    required this.totalPages,
    required this.letters,
  });

  /// JSON 파싱 로직 (API 응답 구조에 맞게)
  factory LetterPageModel.fromJson(Map<String, dynamic> json) {
    final resMsg = json['resMsg'];
    return LetterPageModel(
      opponentId: resMsg['opponentId'] ?? 0, // 상대방 사용자 ID
      opponentName: resMsg['opponentName'] ?? '', // 상대방 사용자 이름
      currentPage: resMsg['currentPage'] ?? 0, //  페이지 정보 상위 레벨에서 가져옴
      totalPages: resMsg['totalPages'] ?? 1,
      letters:
          (resMsg['letters'] as List<dynamic>)
              .map((item) => LetterDetailModel.fromJson(item))
              .toList(),
    );
  }
}
