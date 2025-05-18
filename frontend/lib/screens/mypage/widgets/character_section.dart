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

            if (kDebugMode) {
              print('마이페이지: 현재 캐릭터: $userCharacter');
            }

            // 캐릭터 인덱스 찾기
            int characterIndex = 0;
            for (int i = 0; i < CharacterData.characterCount; i++) {
              final characterName = CharacterData.getName(i);
              if (kDebugMode) {
                print(
                  '마이페이지: 비교 중 - $characterName vs $userCharacter',
                );
              }
              if (characterName == userCharacter) {
                characterIndex = i;
                if (kDebugMode) {
                  print('마이페이지: 캐릭터 인덱스 찾음: $i');
                }
                break;
              }
            }

            return Column(
              children: [
                GestureDetector(
                  onTap: () => showCharacterSelectBottomSheet(
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
