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
    '누군가 나를 이해해준다고 느끼기 어렵다.',
    '하루 종일 거의 혼자 시간을 보낸다.',
    '사람들과 연락(카톡, 전화 등)을 자주 하지 않는다.',
    '혼자 있는 것이 더 편하다고 느낀다.',
    '사회나 조직의 규칙이 나와는 잘 맞지 않는다고 느낀다.',
    '나는 익숙한 장소보다는 새로운 장소를 탐험하는 것을 즐긴다.',
    '혼자서 하는 활동보다 누군가와 함께하는 활동이 더 재미있다.',
    '하루 일과가 일정하게 반복되는 게 마음이 편하다.',
    '조용하고 아늑한 공간에서 보내는 시간이 가장 좋다.',
    '생각이나 감정을 글이나 그림으로 표현하는 것을 좋아한다.',
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                ...List.generate(
                  questions.length,
                      (idx) => Padding(
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
                        const SizedBox(height: 24),

                        // 선택지 라인 + 원
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
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: selectedIndexes[idx] == i
                                        ? const Color(0xFF9BE3D7)
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 6),
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
                ),

                // 관심 태그
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '관심 태그를 선택하세요',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Wrap(
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
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
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
              ],
            ),
          ),

          // 제출 버튼
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: () {
                  print(selectedIndexes);
                  print(selectedTags);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                ),
                child: const Text('제출하기', style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
