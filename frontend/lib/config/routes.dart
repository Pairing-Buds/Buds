// 라우트 설정

import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/diary/diary_list_screen.dart';
import '../screens/diary/diary_detail_screen.dart';
// import '../screens/login/login_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.home: (context) => const HomeScreen(),
    //RouteNames.diaryList: (context) => const DiaryListScreen(),
    // RouteNames.login: (context) => const LoginScreen(),

    // 매개변수가 필요한 경로는 여기서 제외하고 generateRoute에서 처리
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 매개변수가 있는 라우트 처리 (예: diary/:id)
    // if (settings.name?.startsWith(RouteNames.diaryDetail) ?? false) {
    //   // 예시: diary/123 형태를 파싱하여 id만 추출
    //   final id = settings.name?.split('/').last;
    //   return MaterialPageRoute(builder: (_) => DiaryDetailScreen(id: id ?? ''));
    // }

    // 없는 라우트 처리
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
    );
  }

  // 네비게이션 헬퍼 메서드
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // 이전 화면으로 돌아가기
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
