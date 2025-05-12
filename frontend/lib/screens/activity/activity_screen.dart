import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/activity/shell_screen.dart';
import 'package:buds/screens/activity/widgets/book_recommendation.dart';
import 'package:buds/screens/activity/widgets/user_recommendation.dart';
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
              '추천활동을 하고 편지를 받아봐요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ActivityBox(
                  imagePath: 'assets/icons/book_icon.png',
                  label: '도서관가기',
                  color: Color(0xFFE6F7FF),
                ),
                const ActivityBox(
                  imagePath: 'assets/icons/tree_icon.png',
                  label: '공원가기',
                  color: Color(0xFFE6FFE6),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShellScreen()),
                    );
                  },
                  child: const ActivityBox(
                    imagePath: 'assets/icons/shell_icon.png',
                    label: '필사하기',
                    color: Color(0xFFFFF8E6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const BookRecommendation(),
            const SizedBox(height: 32),
            const UserRecommendation(),
          ],
        ),
      ),
    );
  }
}

class ActivityBox extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;

  const ActivityBox({
    required this.imagePath,
    required this.label,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 130, // 높이 살짝 조정
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
