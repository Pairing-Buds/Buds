import 'package:flutter/material.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/screens/activity/widgets/book_recommendation.dart';

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
            // const SizedBox(height: 2),
            const Text(
              '오늘 이런 활동 어때요?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ActivityBox(
                  icon: Icons.book,
                  label: '도서관 가기',
                  color: Color(0xFFE6F7FF),
                ),
                ActivityBox(
                  icon: Icons.park,
                  label: '공원 가기',
                  color: Color(0xFFF0FFE6),
                ),
                ActivityBox(
                  icon: Icons.edit,
                  label: '필사 하기',
                  color: Color(0xFFFFF8E6),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const BookRecommendation(),
            const SizedBox(height: 32),
            const Text(
              '취향에 맞는 친구 찾기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      width: 80,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
