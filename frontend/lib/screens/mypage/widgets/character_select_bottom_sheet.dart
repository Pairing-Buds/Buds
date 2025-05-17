// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/character/models/character_data.dart';
import 'package:buds/widgets/toast_bar.dart';

class CharacterSelectBottomSheet extends StatefulWidget {
  final AuthProvider authProvider;
  final int currentCharacterIndex;

  const CharacterSelectBottomSheet({
    Key? key,
    required this.authProvider,
    required this.currentCharacterIndex,
  }) : super(key: key);

  @override
  State<CharacterSelectBottomSheet> createState() => _CharacterSelectBottomSheetState();
}

class _CharacterSelectBottomSheetState extends State<CharacterSelectBottomSheet> {
  late int selectedCharacterIndex;

  @override
  void initState() {
    super.initState();
    selectedCharacterIndex = widget.currentCharacterIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 부분
          Row(
            children: [
              Image.asset(
                'assets/icons/characters/newmarmet.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
              const Text(
                '캐릭터 변경하기',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '마음에 드는 캐릭터를 선택해주세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // 캐릭터 그리드
          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: CharacterData.characterCount,
                itemBuilder: (context, index) {
                  final isSelected = selectedCharacterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCharacterIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 체크 아이콘 (선택된 경우에만)
                          if (isSelected)
                            const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                  top: 8.0,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 12,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),

                          // 캐릭터 이미지
                          Image.asset(
                            CharacterData.getImage(index),
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 8),

                          // 캐릭터 이름
                          Text(
                            CharacterData.getName(index),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.black87,
                            ),
                          ),

                          // 캐릭터 설명 (선택된 경우에만)
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                CharacterData.getDescription(index).split('!')[0].substring(
                                          0,
                                          CharacterData.getDescription(index).split('!')[0].length > 20
                                              ? 20
                                              : CharacterData.getDescription(index).split('!')[0].length,
                                        ) +
                                    '..!',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          // 변경하기 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _updateUserCharacter(
                  context,
                  widget.authProvider,
                  CharacterData.getName(selectedCharacterIndex),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '변경하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 사용자 캐릭터 업데이트
  Future<void> _updateUserCharacter(
    BuildContext context,
    AuthProvider authProvider,
    String characterName,
  ) async {
    try {
      final result = await authProvider.updateUserCharacter(characterName);

      if (result) {
        if (context.mounted) {
          Toast(
            context,
            '$characterName(으)로 캐릭터가 변경되었습니다.',
            icon: const Icon(Icons.check_circle, color: Colors.green),
          );
        }
      } else {
        if (context.mounted) {
          Toast(
            context,
            '캐릭터 변경에 실패했습니다. 다시 시도해주세요.',
            icon: const Icon(Icons.error, color: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Toast(
          context,
          '오류가 발생했습니다: $e',
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    }
  }
}

// 바텀시트를 표시하는 메서드
void showCharacterSelectBottomSheet(
  BuildContext context, 
  AuthProvider authProvider, 
  int currentCharacterIndex,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return CharacterSelectBottomSheet(
        authProvider: authProvider,
        currentCharacterIndex: currentCharacterIndex,
      );
    },
  );
} 