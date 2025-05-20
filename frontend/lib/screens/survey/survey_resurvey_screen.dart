import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/services/survey_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';

class SurveyResurveyScreen extends StatefulWidget {
  const SurveyResurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyResurveyScreen> createState() => _SurveyResurveyScreenState();
}

class _SurveyResurveyScreenState extends State<SurveyResurveyScreen> {
  final List<String> labels = ['전혀\n아니다', ' ', '보통', ' ', '완전\n그렇다'];

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

  void submitSurvey() async {
    if (selectedIndexes.contains(null)) {
      Toast(context, '설문조사가 끝나지 않았습니다. 모든 질문에 응답해주세요.');
      return;
    }

    try {
      int seclusionScore = selectedIndexes
          .sublist(0, 10)
          .fold(0, (sum, score) => sum + (score ?? 0));
      int opennessScore = selectedIndexes[10] ?? 0;
      int sociabilityScore = selectedIndexes[11] ?? 0;
      int routineScore = selectedIndexes[12] ?? 0;
      int quietnessScore = selectedIndexes[13] ?? 0;
      int expressionScore = selectedIndexes[14] ?? 0;

      bool success = await SurveyService().resurveySubmit(
        seclusionScore: seclusionScore,
        opennessScore: opennessScore,
        sociabilityScore: sociabilityScore,
        routineScore: routineScore,
        quietnessScore: quietnessScore,
        expressionScore: expressionScore,
      );

      if (success) {
        Toast(context, '설문조사 결과가 제출되었습니다.');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Toast(context, '제출에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      Toast(context, '제출 중 오류 발생. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '재설문조사', centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 진행바
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('유저님의 성향은?', style: TextStyle(fontSize: 18)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              '조사 결과를 바탕으로 활동을 추천해드려요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          // 질문 목록과 관심태그를 포함한 스크롤 영역
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                // 질문 목록 부분
                ...List.generate(
                  questions.length,
                  (idx) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 질문 번호 + 내용
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFFFA255),
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  fontFamily: 'MangoDdobak',
                                  fontSize: 23,
                                  color: Colors.black,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  child: Container(
                                    height: 2,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            backgroundColor:
                                                selectedIndexes[idx] == i
                                                    ? const Color(0xFF9BE3D7)
                                                    : Colors.grey.shade300,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            labels[i],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
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
                      ],
                    ),
                  ),
                ),

                // 제출 버튼
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 40,
                  ), // 바닥에 20의 패딩 추가
                  child: Center(
                    child: ElevatedButton(
                      onPressed: submitSurvey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('제출하기'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
