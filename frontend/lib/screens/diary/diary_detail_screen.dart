import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:buds/widgets/common_dialog.dart';
import 'package:buds/services/diary_service.dart';
import 'package:buds/models/diary_create_model.dart';
import 'package:buds/screens/diary/widgets/diary_card.dart';

class DiaryDetailScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryDetailScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  String emotionContent = '';
  String activityContent = '';

  void _showDeleteDialog() {
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
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleSave() async {
    if (emotionContent.trim().isEmpty && activityContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    final diary = DiaryCreateRequest(
      emotionDiary: emotionContent,
      activeDiary: activityContent,
      date: widget.selectedDate.toIso8601String().split('T')[0],
    );

    final success = await DiaryService().createDiary(
      emotionDiary: diary.emotionDiary,
      activeDiary: diary.activeDiary,
      date: diary.date,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기가 저장되었습니다.')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기 저장에 실패했습니다.')),
        );
      }
    }
  }

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
            Container(
              width: 80,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _showDeleteDialog,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: DiaryCard(
                date: widget.selectedDate,
                badgeIcons: const [],
                emotionContent: emotionContent,
                activityContent: activityContent,
                showEditButton: false,
                showRecordButton: false,
                hasShadow: false,
                onEmotionChanged: (text) => setState(() => emotionContent = text),
                onActivityChanged: (text) => setState(() => activityContent = text),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('저장하기', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
