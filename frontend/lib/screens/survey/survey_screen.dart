// survey_screen.dart
import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/services/dio_survey.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final List<String> labels = [
    '전혀\n아니다',
    '',
    '보통',
    '',
    '완전\n그렇다',
  ];

  final List<String> questions = [
    '나는 대부분의 시간을 집 안에서 보낸다.',
    '사람들과 만나는 것이 부담스럽거나 피하고 싶다.',
    '중요한 고민을 말할 사람이 거의 없다.',
    '집 밖으로 나가는 일이 귀찮거나 싫다.',
    '다른 사람들과 어울리는 게 즐겁지 않다.',
  ];

  List<int?> selectedIndexes = List.filled(15, null);
  List<String> surveyTags = [];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    loadSurveyTags();
  }

  Future<void> loadSurveyTags() async {
    final tags = await SurveyService().fetchSurveyTags();
    setState(() {
      surveyTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '설문조사',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: MediaQuery.of(context).size.width * 0.3,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '유저님의 성향은?',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              '설문조사 결과를 바탕으로 활동을 추천해드려요',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: questions.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFD2F0EB),
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontFamily: 'MangoDdobak',
                                fontSize: 23,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              questions[idx],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 선택지 라인 + 원
                      SizedBox(
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(5, (i) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndexes[idx] = i;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: selectedIndexes[idx] == i
                                            ? AppColors.primary
                                            : Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        labels[i],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 관심 태그
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '관심 태그를 선택하세요',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Center(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: surveyTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedTags.remove(tag);
                      } else {
                        selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.skyblue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 제출 버튼
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: () {
                  print('Selected Indexes: $selectedIndexes');
                  print('Selected Tags: $selectedTags');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                ),
                child: const Text(
                  '제출하기',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
