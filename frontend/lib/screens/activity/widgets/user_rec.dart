import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/auth_provider.dart';
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
        recommendedUsers = users; // 추천 사용자 관련
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final senderName =
        authProvider.userData?['name'] ?? '나'; // ✅ 로그인 사용자 이름 (보내는 사람)

    // 화면 크기에 따른 반응형 설정
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
                  final userName = user.userName ?? '익명'; // 사용자 이름 (받는 사람)

                  return GestureDetector(
                    onTap: () {
                      if (user.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LetterAnswerScreen(
                                  userId: user.userId,
                                  senderName: senderName,
                                  receiverName: userName,
                                ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 13),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/rec_letter_icon.png'),
                          fit: BoxFit.cover,
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
                          // 사용자 이름 (상단 유지, 공백 기준 2줄)
                          Positioned(
                            top: topPadding,
                            left: 0,
                            right: 0,
                            child: _buildTwoLineName(userName, fontSize),
                          ),
                          // 태그 (아래 중앙)
                          Positioned(
                            bottom: 4,
                            left: 0,
                            right: 0,
                            child: _buildTagLines(user.tagTypes, fontSize),
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

  // 사용자 이름을 공백 기준 2줄로 분리하는 함수
  Widget _buildTwoLineName(String userName, double fontSize) {
    final splitName = userName.split(' ');
    final firstLine = splitName.first; // 첫 번째 단어 (첫 줄)
    final secondLine = splitName.sublist(1).join(' '); // 나머지 (두 번째 줄)

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          firstLine,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            height: 1.3, // 줄 간격 조정
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          secondLine,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            height: 1.1, // 줄 간격 조정
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ⭐ 태그를 중앙 2줄로 정렬 (첫 줄 2개, 둘째 줄 1개)
  Widget _buildTagLines(List<String> tags, double fontSize) {
    final List<Widget> tagWidgets =
        tags
            .map(
              (tag) => Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2723),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: fontSize * 0.7,
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (tagWidgets.length >= 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tagWidgets.take(2).toList(),
          ),
        if (tagWidgets.length > 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [tagWidgets[2]],
          ),
      ],
    );
  }
}
