// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/services/survey_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';

class SurveyRetagScreen extends StatefulWidget {
  const SurveyRetagScreen({Key? key}) : super(key: key);

  @override
  State<SurveyRetagScreen> createState() => _SurveyRetagScreenState();
}

class _SurveyRetagScreenState extends State<SurveyRetagScreen> {
  final List<String> surveyTags = [
    '취업',
    '자격증',
    '운동',
    '패션',
    '음악',
    '독서',
    '요리',
    '게임',
    '만화',
    '영화',
  ];

  List<String> selectedTags = [];

  void submitRetag() async {
    bool success = await SurveyService().submitRetagResult(tags: selectedTags);

    if (success) {
      Toast(context, '관심 분야가 제출되었습니다.');
      if (mounted) Navigator.pop(context);
    } else {
      Toast(context, '제출에 실패했습니다. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '관심 분야 재선택',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('관심 분야 태그를 선택하세요', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text(
              '관심분야를 클릭하지 않고 제출하면 관심분야가 삭제됩니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  surveyTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTags.remove(tag);
                          } else if (selectedTags.length < 3) {
                            selectedTags.add(tag);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Color(0xFFFFA255)
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitRetag,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('제출하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
