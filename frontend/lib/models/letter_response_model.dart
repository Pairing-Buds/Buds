// Project imports:
import 'package:buds/models/letter_list_model.dart';

class LetterResponseModel {
  final int letterCnt;
  final List<LetterModel> letters;

  LetterResponseModel({
    required this.letterCnt,
    required this.letters,
  });

  factory LetterResponseModel.fromJson(Map<String, dynamic> json) {
    final resMsg = json['resMsg'] ?? {};
    return LetterResponseModel(
      letterCnt: resMsg['letterCnt'] ?? 0,
      letters: (resMsg['chatList'] as List<dynamic>? ?? [])
          .map((json) => LetterModel.fromJson(json))
          .toList(),
    );
  }
}
