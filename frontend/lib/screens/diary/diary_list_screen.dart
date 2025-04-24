import 'package:flutter/material.dart';
import '../../models/diary_model.dart';
import '../../config/theme.dart';

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      body: SafeArea(
      child: Column(
        children: [
          // 상단 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back),
                    const Spacer(),
                    const Text(
                      '2025년 4월',
                      style: TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    width: 110,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 6),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildDiaryCard(
                  date: DateTime(2025, 4, 19),
                  moodIcons: ['😎', '😊', '🏠'],
                  content:
                  '이사한 친구 집들이를 갔다. 후식으로 디저트 먹었는데 우리집 근처에도 팔았으면 좋겠다.',
                  additionalNote: '3000보 달성!\n친구 집까지 이동했다.',
                ),
                SizedBox(height: 16),
                _buildDiaryCard(
                  date: DateTime(2025, 4, 20),
                  moodIcons: ['⏰', '📝'],
                  content:
                  '이사한 친구 집들이를 갔다. 후식으로 디저트 먹었는데 우리집 근처에도 팔았으면 좋겠다.',
                  additionalNote: '3000보 달성!\n친구 집까지 이동했다.',
                ),
                SizedBox(height: 16),
                _buildDiaryCard(
                  date: DateTime(2025, 4, 20),
                  moodIcons: ['⏰', '📝'],
                  content:
                  '이사한 친구 집들이를 갔다. 후식으로 디저트 먹었는데 우리집 근처에도 팔았으면 좋겠다.',
                  additionalNote: '3000보 달성!\n친구 집까지 이동했다.',
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDiaryCard({
    required DateTime date,
    required List<String> moodIcons,
    required String content,
    String? additionalNote,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: moodIcons
                .map((icon) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ))
                .toList(),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              '${date.year}. ${_twoDigits(date.month)}. ${_twoDigits(date.day)} ${_weekdayKor(date.weekday)}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 16),

          badgeLabel('감정일기'),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),

          if (additionalNote != null && additionalNote.isNotEmpty) ...[
            const SizedBox(height: 16),
            badgeLabel('활동일기'),
            const SizedBox(height: 4),
            Text(
              additionalNote,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget badgeLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _weekdayKor(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }
}
