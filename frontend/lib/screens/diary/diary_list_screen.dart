import 'package:flutter/material.dart';
import '../../models/diary_model.dart';
import '../../config/theme.dart';
import 'package:buds/screens/calendar/calendar_screen.dart';
import 'package:buds/screens/diary/widgets/diary_card.dart';
import 'package:buds/widgets/toast_bar.dart';

class DiaryListScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DiaryListScreen({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Toast(context, '일기가 저장되었습니다.', icon: Icon(Icons.book, color: Colors.yellow));
    });

    return Scaffold(
        backgroundColor: Colors.white,
      body: SafeArea(
      child: Column(
        children: [
          // 상단 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CalendarScreen()),
                      );
                    },
                  ),
                ),
                Center(
                  child: Text(
                    '${selectedDate.year}년 ${selectedDate.month}월',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

          SizedBox(height: 6),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(32),
              children: [
                _buildDiaryCard(
                  date: DateTime(2025, 4, 19),
                  moodIcons: ['😎', '😊', '🏠'],
                  content:
                  '이사한 친구 집들이를 갔다. 후식으로 디저트 먹었는데 우리집 근처에도 팔았으면 좋겠다.',
                  additionalNote: '3000보 달성!\n친구 집까지 이동했다.',
                ),
                SizedBox(height: 32),
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
    return DiaryCard(
      date: date,
      badgeIcons: [
        'assets/icons/badges/3000.png',
      ],
      emotionContent: content,
      activityContent: additionalNote ?? '',
      showEditButton: false,
      showRecordButton: false,
      hasShadow: true,
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
