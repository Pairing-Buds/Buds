import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buds/models/badge_model.dart';
import 'package:buds/constants/api_constants.dart';

class CalendarService {
  static Future<Map<int, List<BadgeModel>>> fetchMonthlyBadges(String date, int userId) async {
    final uri = Uri.parse('${ApiConstants.calendarDiaryUrl}$date');

    final response = await http.get(uri, headers: {
      'userId': userId.toString(),
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final badgeMap = <int, List<BadgeModel>>{};

      for (var item in data) {
        final day = DateTime.parse(item['date']).day;

        final diaryList = item['diaryList'] as List;
        final badgeList = diaryList
            .map((d) => BadgeModel.fromDiaryType(d['diaryType']))
            .toList();

        badgeMap[day] = badgeList;
      }

      return badgeMap;
    } else {
      throw Exception('캘린더 일기 기반 뱃지 조회 실패: ${response.statusCode}');
    }
  }
}
