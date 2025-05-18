// import 'package:flutter/material.dart';
// import 'package:buds/config/theme.dart';
// import 'package:buds/services/survey_service.dart';
// import 'package:buds/widgets/custom_app_bar.dart';
// import 'package:buds/widgets/toast_bar.dart';
//
//
// // screens/personality_update_screen.dart - 새로운 화면
// class PersonalityUpdateScreen extends StatefulWidget {
//   const PersonalityUpdateScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PersonalityUpdateScreen> createState() => _PersonalityUpdateScreenState();
// }
//
// class _PersonalityUpdateScreenState extends State<PersonalityUpdateScreen> {
//   // 기존 SurveyScreen에서 태그 관련 부분만 제외하고 대부분 복사
//   final List<String> labels = ['전혀\n아니다', '', '보통', '', '완전\n그렇다'];
//   final List<String> questions = [
//     '나는 대부분의 시간을 집 안에서 보낸다.',
//     '사람들과 만나는 것이 부담스럽거나 피하고 싶다.',
//     '중요한 고민을 말할 사람이 거의 없다.',
//     '집 밖으로 나가는 일이 귀찮거나 싫다.',
//     '다른 사람들과 어울리는 게 즐겁지 않다.',
//     '누군가 나를 이해해준다고 느끼기 어렵다.',
//     '하루 종일 거의 혼자 시간을 보낸다.',
//     '사람들과 연락(카톡, 전화 등)을 자주 하지 않는다.',
//     '혼자 있는 것이 더 편하다고 느낀다.',
//     '사회나 조직의 규칙이 나와는 잘 맞지 않는다고 느낀다.',
//     '나는 익숙한 장소보다는 새로운 장소를 탐험하는 것을 즐긴다.',
//     '혼자서 하는 활동보다 누군가와 함께하는 활동이 더 재미있다.',
//     '하루 일과가 일정하게 반복되는 게 마음이 편하다.',
//     '조용하고 아늑한 공간에서 보내는 시간이 가장 좋다.',
//     '생각이나 감정을 글이나 그림으로 표현하는 것을 좋아한다.',
//   ];
//   List<int?> selectedIndexes = List.filled(15, null);
//
//   void submitPersonality() async {
//     if (selectedIndexes.contains(null)) {
//       Toast(context, '설문조사가 끝나지 않았습니다. 모든 질문에 응답해주세요.');
//       return;
//     }
//
//     // 점수 계산 (기존과 동일)
//     int seclusionScore = selectedIndexes
//         .sublist(0, 10)
//         .fold(0, (sum, score) => sum + (score ?? 0));
//     int opennessScore = selectedIndexes[10] ?? 0;
//     int sociabilityScore = selectedIndexes[11] ?? 0;
//     int routineScore = selectedIndexes[12] ?? 0;
//     int quietnessScore = selectedIndexes[13] ?? 0;
//     int expressionScore = selectedIndexes[14] ?? 0;
//
//     // 새로운 API 호출
//     bool success = await SurveyService().updatePersonality(
//       seclusionScore: seclusionScore,
//       opennessScore: opennessScore,
//       sociabilityScore: sociabilityScore,
//       routineScore: routineScore,
//       quietnessScore: quietnessScore,
//       expressionScore: expressionScore,
//     );
//
//     if (success) {
//       Toast(
//         context,
//         '성향 설문조사 결과가 업데이트되었습니다.',
//         icon: const Icon(Icons.check_circle, color: Colors.green),
//       );
//
//       // 마이페이지로 돌아가기
//       Navigator.pop(context);
//     } else {
//       Toast(
//         context,
//         '제출에 실패했습니다. 다시 시도해주세요.',
//         icon: const Icon(Icons.error, color: Colors.red),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: '성향 재설문조사',
//         centerTitle: true,
//         showBackButton: true,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 상단 진행바
//           Container(
//             height: 4,
//             width: MediaQuery.of(context).size.width * 1,
//             color: AppColors.primary,
//           ),
//
//           const SizedBox(height: 20),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Text('유저님의 성향을 업데이트해주세요', style: TextStyle(fontSize: 18)),
//           ),
//
//           // 질문 목록 부분 (기존 코드와 동일)
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               children: [
//                 ...List.generate(
//                   questions.length,
//                       (idx) => Padding(
//                     // 기존 질문 UI와 동일
//                   ),
//                 ),
//
//                 // 제출 버튼
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
//                     child: ElevatedButton(
//                       onPressed: submitPersonality, // 새로운 제출 메서드 사용
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 60,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: const Text(
//                         '업데이트하기',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }