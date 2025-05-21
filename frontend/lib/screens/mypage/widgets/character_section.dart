// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/character/models/character_data.dart';
import 'package:buds/screens/mypage/widgets/character_select_bottom_sheet.dart';

/// 캐릭터 섹션 위젯
class CharacterSection extends StatelessWidget {
  const CharacterSection({Key? key}) : super(key: key);

  // 서버 캐릭터 이름을 인덱스로 변환
  int getCharacterIndex(String? serverCharacterName) {
    if (serverCharacterName == null || serverCharacterName.isEmpty) {
      return 0; // 기본값
    }

    // 서버 캐릭터 이름 대소문자 처리
    String normalizedName = serverCharacterName.toUpperCase();

    // 서버에서 받은 캐릭터 이름과 앱 내 캐릭터 매핑
    Map<String, int> characterMap = {
      '오리': 0,
      'DUCK': 0,
      '고양이': 1,
      'FOX': 1,
      'CAT': 1,
      '개구리': 2,
      'FROG': 2,
      '게코': 3,
      'GECKO': 3,
      'LIZARD': 3,
      '마멋': 4,
      'MARMET': 4,
      'MARMOT': 4,
      '토끼': 5,
      'RABBIT': 5,
      'RABIT': 5,
      'BUDDY': 4, // 기본 캐릭터는 마멋으로 설정
    };

    return characterMap[normalizedName] ?? 4; // 기본값으로 마멋(4) 반환
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text('나의 캐릭터', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 16),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final userCharacter = authProvider.userData?['userCharacter'];
            final userName = authProvider.userData?['name'] ?? '사용자';

            // 캐릭터 인덱스 찾기 (새로운 메서드 사용)
            int characterIndex = getCharacterIndex(userCharacter);

            return Column(
              children: [
                GestureDetector(
                  onTap:
                      () => showCharacterSelectBottomSheet(
                        context,
                        authProvider,
                        characterIndex,
                      ),
                  child: Image.asset(
                    CharacterData.getMyPageImage(characterIndex),
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
