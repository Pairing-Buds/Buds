import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';

/// 캐릭터 데이터를 관리하는 클래스
class CharacterData {
  // 캐릭터 이미지 경로 가져오기
  static String getImage(int index) {
    switch (index) {
      case 0:
        return 'assets/images/duck.png'; // 오리
      case 1:
        return 'assets/images/fox.png'; // 여우
      case 2:
        return 'assets/images/frog.png'; // 개구리
      case 3:
        return 'assets/images/lizard.png'; // 도마뱀
      case 4:
        return 'assets/images/newmarmet.png'; // 마멧
      case 5:
        return 'assets/images/rabit.png'; // 토끼
      default:
        return 'assets/images/duck.png';
    }
  }

  // 캐릭터 이름 가져오기
  static String getName(int index) {
    switch (index) {
      case 0:
        return '오리'; // 오리
      case 1:
        return '여우'; // 여우
      case 2:
        return '개구리'; // 개구리
      case 3:
        return '도마뱀'; // 도마뱀
      case 4:
        return '마멧'; // 마멧
      case 5:
        return '토끼'; // 토끼
      default:
        return '캐릭터';
    }
  }

  // 캐릭터 설명 가져오기
  static String getDescription(int index) {
    switch (index) {
      case 0:
        return '귀엽고 친근한 오리와 함께 섬에서 새로운 모험을 시작해보세요!';
      case 1:
        return '영리하고 따뜻한 여우와 함께 특별한 이야기를 만들어보세요!';
      case 2:
        return '활발하고 즐거운 개구리와 함께라면 매일이 신나는 일로 가득할 거예요!';
      case 3:
        return '호기심 많고 재치있는 도마뱀이 당신의 일상을 더 풍요롭게 만들어줄 거예요!';
      case 4:
        return '다정하고 사려깊은 마멧이 당신에게 따뜻한 위로를 전해줄 거예요!';
      case 5:
        return '귀엽고 상냥한 토끼와 함께 당신의 섬을 꾸며보세요!';
      default:
        return '당신과 함께할 특별한 친구입니다.';
    }
  }
}

/// 헤더 텍스트 위젯
class HeaderText extends StatelessWidget {
  const HeaderText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: const [
          Text(
            '거주할 섬이 생성 되었습니다!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '함께 할 캐릭터를 선택해 주세요',
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 푸터 텍스트 위젯
class FooterText extends StatelessWidget {
  const FooterText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        '캐릭터는 마이페이지에서 변경 가능합니다!',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 페이지 인디케이터 위젯
class PageIndicator extends StatelessWidget {
  final int currentPage;

  const PageIndicator({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6, // 캐릭터 개수 (6개)
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentPage == index ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

/// 캐릭터 카드 위젯
class CharacterCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const CharacterCard({Key? key, required this.index, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 캐릭터 이미지
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    CharacterData.getImage(index),
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    color: Colors.black.withOpacity(0.95),
                    colorBlendMode: BlendMode.srcATop,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_outline,
                        size: 120,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 바텀 시트 위젯
class CharacterBottomSheet extends StatelessWidget {
  final int index;
  final VoidCallback onSelect;

  const CharacterBottomSheet({
    Key? key,
    required this.index,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 바텀 시트 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 내용 비움 (추후 작업 예정)
          const Expanded(
            child: Center(
              child: Text(
                '추후 작업 예정',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

          // 캐릭터 선택 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '이 캐릭터와 함께하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
