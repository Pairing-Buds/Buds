// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/models/diary_model.dart';
import 'package:buds/screens/diary/widgets/diary_card.dart';
import 'package:buds/services/diary_service.dart';
import 'package:buds/widgets/toast_bar.dart';

class EditDiaryBottomSheet extends StatefulWidget {
  final DiaryDay diaryDay;
  final VoidCallback onUpdated;

  const EditDiaryBottomSheet({
    Key? key,
    required this.diaryDay,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<EditDiaryBottomSheet> createState() => _EditDiaryBottomSheetState();
}

class _EditDiaryBottomSheetState extends State<EditDiaryBottomSheet> {
  late TextEditingController _emotionController;
  late TextEditingController _activeController;

  @override
  void initState() {
    super.initState();
    _emotionController = TextEditingController(
      text: widget.diaryDay.diaryList
          .firstWhere((d) => d.diaryType == 'EMOTION', orElse: () => DiaryEntry.empty())
          .content,
    );
    _activeController = TextEditingController(
      text: widget.diaryDay.diaryList
          .firstWhere((d) => d.diaryType == 'ACTIVE', orElse: () => DiaryEntry.empty())
          .content,
    );
  }

  @override
  void dispose() {
    _emotionController.dispose();
    _activeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final diaryNo = widget.diaryDay.diaryList.first.diaryNo;

    final success = await DiaryService().updateDiary(
      diaryNo: diaryNo,
      emotionDiary: _emotionController.text,
      activeDiary: _activeController.text,
      date: widget.diaryDay.date,
    );

    if (success) {
      Toast(context, '일기가 수정되었습니다.');
      Navigator.pop(context);
      widget.onUpdated();
    } else {
      Toast(context, '수정에 실패했어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DiaryCard(
              date: DateTime.parse(widget.diaryDay.date),
              badgeIcons: widget.diaryDay.badgeList.map((b) => 'assets/icons/badges/$b.png').toList(),
              showEditButton: false,
              showRecordButton: true,
              emotionController: _emotionController,
              activityController: _activeController,
              onRecordPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
