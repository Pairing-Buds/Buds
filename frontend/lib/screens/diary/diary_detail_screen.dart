import 'package:flutter/material.dart';
import '../../config/theme.dart'; // AppColors.primary 등
import 'package:buds/screens/diary/widgets/diary_card.dart';
import 'package:buds/widgets/common_dialog.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DateTime? diaryDate;
  final List<String>? moodIcons;
  final String? emotionContent;
  final String? activityContent;

  const DiaryDetailScreen({
    Key? key,
    this.diaryDate,
    this.moodIcons,
    this.emotionContent,
    this.activityContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            const Text('오늘의 일기', style: TextStyle(color: Colors.black, fontSize: 18)),
            const SizedBox(height: 4),
            Container(width: 80, height: 3, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => CommonDialog(
                  title: '삭제하시겠어요?',
                  description: '작성 중인 일기는 저장되지 않아요.',
                  cancelText: '취소',
                  confirmText: '삭제',
                  confirmColor: Colors.redAccent,
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () {
                    Navigator.pop(context); // 닫기
                    Navigator.pop(context); // DiaryDetailScreen 닫기
                  },
                ),
              );
            },
          )
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: DiaryCard(
                date: diaryDate ?? DateTime.now(),
                badgeIcons: [
                  'assets/icons/badges/3000.png',
                  'assets/icons/badges/library.png',
                  'assets/icons/badges/wake.png',
                ],
                emotionContent: emotionContent ?? '이사한 친구 집들이를 갔다. 후식으로 러스크를 먹었는데 우리 집에도 팔았으면 좋겠다.',
                activityContent: activityContent ?? '3000보 달성!\n친구 집까지 이동했다',
                showEditButton: true,
                showRecordButton: true,
                hasShadow: false,

                onEditPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => CommonDialog(
                      title: '수정하시겠어요?',
                      description: '오늘만 수정이 가능합니다.',
                      cancelText: '취소',
                      confirmText: '수정하기',
                      confirmColor: AppColors.primary,
                      onCancel: () => Navigator.pop(context),
                      onConfirm: () {
                        Navigator.pop(context);
                        // TODO: 수정 화면 이동 or 수정 처리
                      },
                    ),
                  );
                },
              )
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  static String _weekdayKor(int weekday) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return weekdays[weekday - 1];
  }
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            );
          }),
        );
      },
    );
  }
}
