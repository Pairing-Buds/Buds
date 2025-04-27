import 'package:flutter/material.dart';

class AppColors {
  //누렁이 색상
  static const Color primary = Color(0xFFF4D6A2);

  // 배경색
  static const Color background = Color(0xFFF9F9F9);

  // 배너색
  static const Color banner = Color(0xFFE9F9E7);
  // 카카오 색상
  static const Color kakao = Color(0xFFFEE500);
  //무슨색인지 나도 모름
  static const Color text = Color(0xFFF2FEFF);
  // 텍스트 색상
  static const Color toast = Color(0xFF828282);
  // 일기 채팅 배경색
  static const Color cardBackground = Color(0xFFFFFDF4);

  // 회원가입 회색 색상
  static const Color gray = Color(0xFFEEEEEE);
  // static final Color gray = Colors.grey.shade200;
}

final ThemeData appTheme = ThemeData(
  fontFamily: 'GmarketSans',
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primary,
    background: AppColors.background,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 24,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontFamily: 'GmarketSans',
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      minimumSize: const Size(120, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24),
    ),
  ),
);