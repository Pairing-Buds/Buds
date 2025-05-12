import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/models/activity_user_model.dart';

class UserRecommendation extends StatefulWidget {
  const UserRecommendation({Key? key}) : super(key: key);

  @override
  State<UserRecommendation> createState() => _UserRecommendationState();
}

class _UserRecommendationState extends State<UserRecommendation> {
  List<ActivityUserModel> recommendedUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendedUsers();
  }

  Future<void> fetchRecommendedUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final users = await ActivityService().fetchActivityUser();
      setState(() {
        recommendedUsers = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천 사용자 불러오기 실패')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기에 따른 반응형 설정
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.22; // 편지 카드 너비 (전체 화면의 22%)
    final cardHeight = cardWidth * 1.3;   // 편지 카드 높이 (너비 대비 1.3배)
    final fontSize = cardWidth * 0.15;    // 글자 크기 (카드 너비의 15%)
    final topPadding = cardHeight * 0.15; // 글자 상단 여백 (카드 높이의 15%)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '취향에 맞는 친구 찾기',
          style: TextStyle(fontSize: 18),
        ),
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
              final splitName = user.userName.split(' ');

              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/rec_letter_icon.png'),
                    fit: BoxFit.cover, // 아이콘 전체를 배경으로
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
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding), // 반응형 상단 여백
                        child: Text(
                          splitName.length > 1
                              ? splitName.sublist(0, 2).join('\n') // 두 줄로 줄바꿈
                              : user.userName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
