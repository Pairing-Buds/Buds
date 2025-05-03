import 'dart:convert';
import 'package:http/http.dart' as http;

class Letter {
  final int userId;
  final String userName;
  final String lastLetterDate;
  final String lastLetterStatus;
  final bool received;

  Letter({
    required this.userId,
    required this.userName,
    required this.lastLetterDate,
    required this.lastLetterStatus,
    required this.received,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      userId: json['userId'],
      userName: json['userName'],
      lastLetterDate: json['lastLetterDate'],
      lastLetterStatus: json['lastLetterStatus'],
      received: json['received'],
    );
  }
}

class LetterService {
  final String baseUrl = 'http://k12c105.p.ssafy.io'; // Replace with your actual base URL

  // 1. 편지 목록 조회 - letter_list.dart
  Future<List<Letter>> fetchLetters() async {
    final response = await http.get(Uri.parse('$baseUrl/letters/chats'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['statusCode'] == 'OK' && data['resMsg'] != null) {
        final List<dynamic> chatList = data['resMsg']['chatList'];
        return chatList.map((item) => Letter.fromJson(item)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load letters: ${response.statusCode}');
    }
  }

  // 2. 편지 스크랩 기능 - letter_reply.dart
  Future<bool> toggleScrap(int letterId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/letters/scrap'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'letterId': letterId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['statusCode'] == 'OK';
      } else {
        return false;
      }
    } catch (e) {
      print('스크랩 토글 오류: $e');
      return false;
    }
  }
}