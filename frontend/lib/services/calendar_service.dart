import 'package:buds/models/badge_model.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/dio_api_service.dart';

class CalendarService {
  static final DioApiService _dioApiService = DioApiService();

  static Future<Map<int, List<BadgeModel>>> fetchMonthlyBadges(String date) async {
    final path = '/calendars/$date';

    final response = await _dioApiService.get(path);
    final data = response.data;

    if (data['statusCode'] != 'OK') {
      throw Exception('캘린더 배지 조회 실패');
    }

    final resMsg = data['resMsg'] as List<dynamic>;
    final badgeMap = <int, List<BadgeModel>>{};

    for (var item in resMsg) {
      final day = DateTime.parse(item['date']).day;

      // badge가 null이면 스킵
      if (item['badge'] == null) continue;

      final badgeName = item['badge'] as String;
      badgeMap[day] = [
        BadgeModel(imagePath: 'assets/icons/badges/$badgeName.png')
      ];
    }

    return badgeMap;
  }
}
