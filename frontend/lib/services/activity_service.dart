import 'dart:convert';
import 'package:flutter/material.dart'; // 이 줄 추가
import 'package:http/http.dart' as http;

class ActivityService {
  // 1일 50000번 조회 가능
  static const String _ttbKey = "ttbekfa291732001";
  static const String _baseUrl = 'https://www.aladin.co.kr/ttb/api/ItemList.aspx';

  Future<Map<String, String>> fetchMentalHealthBook() async {
    final url = Uri.parse(
      '$_baseUrl?ttbkey=$_ttbKey'
          '&QueryType=ItemEditorChoice'
          '&MaxResults=1'
          '&Start=1'
          '&SearchTarget=Book'
          '&CategoryId=53517'
          '&Output=JS'
          '&Version=20131101',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('응답 데이터: $data'); // ← 여기에 로그 추가

      final items = data['item'];
      if (items == null || items.isEmpty) {
        throw Exception('책 정보 없음 (item 배열이 비어 있음)');
      }

      final item = items[0];
      return {
        'title': item['title'],
        'author': item['author'],
        'cover': item['cover'],
      };
    } else {
      throw Exception('정신건강 도서 조회 실패: ${response.statusCode}');
    }
  }
}