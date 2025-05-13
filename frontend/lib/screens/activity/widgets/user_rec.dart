import 'package:flutter/material.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/models/tag_rec_user_model.dart';
import 'package:buds/screens/letter/letter_answer_screen.dart';

class UserRec extends StatefulWidget {
  const UserRec({Key? key}) : super(key: key);

  @override
  State<UserRec> createState() => _UserRecState();
}

class _UserRecState extends State<UserRec> {
  List<TagRecUserModel> recommendedUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRecUser();
  }

  // ⭐ 추천 사용자 리스트 조회 함수
  Future<void> fetchRecUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final users = await ActivityService().fetchRecUser();
      setState(() {
        recommendedUsers = users; // ⭐ 추천 사용자 관련
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추천 사용자 불러오기 실패')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ 화면 크기에 따른 반응형 설정
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.22; // 편지 카드 너비 (전체 화면의 22%)
    final cardHeight = cardWidth * 1.3; // 편지 카드 높이 (너비 대비 1.3배)
    final fontSize = cardWidth * 0.15; // 글자 크기 (카드 너비의 15%)
    final topPadding = cardHeight * 0.2; // 사용자 이름 위치 유지 (20%)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('취향에 맞는 친구 찾기', style: TextStyle(fontSize: 18)),
        const Text(
          '취향이 같은 친구에게 편지를 보내보아요',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedUsers.length,
                itemBuilder: (context, index) {
                  final user = recommendedUsers[index];
                  final userName =
                      user.userName ?? '알 수 없음'; // ⭐ 사용자 이름 null 안전 처리
                  final splitName = userName.split(' ');

                  return GestureDetector(
                    onTap: () {
                      // ⭐ 사용자 카드 클릭 시 LetterAnswerScreen으로 이동
                      if (user.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LetterAnswerScreen(
                                  userId: user.userId, // ⭐ userId 전달
                                  receiverName: userName,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')),
                        );
                      }
                    },
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 13),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/rec_letter_icon.png'),
                          fit: BoxFit.cover, // ⭐ 아이콘 전체를 배경으로
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // ⭐ 사용자 이름 (상단 유지)
                          Positioned(
                            top: topPadding,
                            left: 0,
                            right: 0,
                            child: Text(
                              splitName.length > 1
                                  ? splitName.sublist(0, 2).join('\n')
                                  : userName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // ⭐ 태그 표시 (하단 둥근 직사각형)
                          Positioned(
                            bottom: 8,
                            left: cardWidth * 0.05,
                            right: cardWidth * 0.05,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3E2723), // 진갈색 배경
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _buildTagLines(
                                  user.tagTypes,
                                  fontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  // ⭐ 태그를 최대 3개로 나눠주는 함수
  List<Widget> _buildTagLines(List<String> tags, double fontSize) {
    if (tags.isEmpty) return [];

    // ⭐ 최대 3개 태그 사용
    final tagList = tags.take(3).toList();

    // ⭐ 태그를 쉼표로 연결
    final tagLine = tagList.join(', ');

    return [
      Text(
        tagLine,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize * 0.75, color: Colors.white),
      ),
    ];
  }
}
