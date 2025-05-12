// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/screens/activity/shell_screen.dart';
import 'package:buds/screens/activity/widgets/book_recommendation.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '오늘의 활동',
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('버즈의 추천활동', style: TextStyle(fontSize: 18)),
            const Text(
              '오늘 이런 활동 어때요?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ActivityBox(
                  icon: Icons.book,
                  label: '도서관 가기',
                  color: AppColors.skyblue,
                ),
                const ActivityBox(
                  icon: Icons.park,
                  label: '공원 가기',
                  color: AppColors.lightgreen,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShellScreen()),
                    );
                  },
                  child: const ActivityBox(
                    icon: Icons.edit,
                    label: '필사 하기',
                    color: Color(0xFFFFF8E6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const BookRecommendation(),
            const SizedBox(height: 32),
            const Text(
              '취향에 맞는 친구 찾기',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                PreferenceBox(label: '에스파'),
                PreferenceBox(label: '뉴진스'),
                PreferenceBox(label: '아이브'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ActivityBox({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class PreferenceBox extends StatelessWidget {
  final String label;

  const PreferenceBox({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
