// 날짜 관련 유틸리티

// Package imports:
import 'package:intl/intl.dart';

class DateUtils {
  // 날짜 포맷 (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 날짜 및 시간 포맷 (YYYY-MM-DD HH:MM)
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  // 요일 반환 (월,화,수...)
  static String getWeekday(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1]; // DateTime의 weekday는 1(월)~7(일)
  }

  // 년월일 형식 포맷
  static String formatYearMonthDay(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // 상대적 시간 표시 (방금 전, 5분 전, 어제...)
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return formatDate(date);
    }
  }

  // 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
