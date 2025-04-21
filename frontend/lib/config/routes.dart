// 라우트 설정

import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/diary/diary_list_screen.dart';
import '../screens/diary/diary_detail_screen.dart';
import '../screens/login/login_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.diaryList:
        return MaterialPageRoute(builder: (_) => const DiaryListScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        // 매개변수가 있는 라우트 처리 (예: diary/:id)
        if (settings.name?.startsWith(RouteNames.diaryDetail) ?? false) {
          // 예시: diary/123 형태를 파싱하여 id만 추출
          final id = settings.name?.split('/').last;
          return MaterialPageRoute(
            builder: (_) => DiaryDetailScreen(id: id ?? ''),
          );
        }

        // 없는 라우트 처리
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
