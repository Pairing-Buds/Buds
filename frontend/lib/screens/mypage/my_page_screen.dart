// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/character_provider.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:buds/screens/character/models/character_data.dart';
import 'package:buds/screens/customercenter/customer_center_screen.dart';
import 'package:buds/screens/mypage/withdraw_screen.dart';
import 'package:buds/screens/step/step_detail_screen.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'package:buds/config/theme.dart';
import 'widgets/step_section.dart';
import 'widgets/wake_up_section.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRedirectAnonymousUser();
    });
  }

  // 익명 사용자 체크 및 리디렉션
  void _checkAndRedirectAnonymousUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 내 정보 새로 가져오기
    authProvider
        .refreshUserData()
        .then((_) {
          if (kDebugMode) {
            print('마이페이지: 내 정보 조회 완료');
            print('마이페이지: 익명 사용자 여부: ${authProvider.isAnonymousUser}');
          }

          // 사용자가 익명인 경우 캐릭터 선택 화면으로 이동
          if (authProvider.isAnonymousUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CharacterSelectScreen(),
              ),
            );
          }
        })
        .catchError((e) {
          if (kDebugMode) {
            print('마이페이지: 내 정보 조회 실패: $e');
          }
          // 실패하더라도 계속 진행
        });
  }

  @override
  Widget build(BuildContext context) {
    // 캐릭터 프로바이더 가져오기
    final characterProvider = Provider.of<CharacterProvider>(context);

    return ChangeNotifierProvider(
      create: (context) => MyPageProvider(characterProvider),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text('나의 캐릭터', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 16),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final userCharacter =
                            authProvider.userData?['userCharacter'];
                        final userName =
                            authProvider.userData?['name'] ?? '사용자';

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
                              onTap:
                                  () => _showCharacterSelectBottomSheet(
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
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        final myPageProvider = Provider.of<MyPageProvider>(
                          context,
                          listen: false,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StepDetailScreen(),
                          ),
                        );
                      },
                      child: const StepSection(),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WakeUpSection 위젯 사용
                    const WakeUpSection(),
                    const SizedBox(height: 20),
                    const Text(
                      '우리지역 센터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 50,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => const CustomerCenterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '고객센터에 문의하기',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const WithdrawScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '회원 탈퇴하기',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.logout();
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                            child: Text(
                              '로그아웃',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // 하단 여백 추가
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 캐릭터 선택 바텀 시트 표시
  void _showCharacterSelectBottomSheet(
    BuildContext context,
    AuthProvider authProvider,
    int currentCharacterIndex,
  ) {
    int selectedCharacterIndex = currentCharacterIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              // 높이를 고정값 대신 디바이스 높이의 일정 비율로 설정
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

                  // 캐릭터 그리드 - Expanded로 감싸고 내부에 SingleChildScrollView 추가
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                        shrinkWrap: true, // 그리드뷰 크기를 내용에 맞게 조정
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: AppColors.primary,
                                          width: 3,
                                        )
                                        : null,
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min, // 크기를 내용에 맞게 조정
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
                                    height: 80, // 이미지 크기 조정
                                    width: 80,
                                  ),
                                  const SizedBox(height: 8),

                                  // 캐릭터 이름
                                  Text(
                                    CharacterData.getName(index),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : Colors.black87,
                                    ),
                                  ),

                                  // 캐릭터 설명 (선택된 경우에만) - 더 짧게 제한
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      child: Text(
                                        // 설명 텍스트를 더 짧게 제한
                                        CharacterData.getDescription(index)
                                                .split('!')[0]
                                                .substring(
                                                  0,
                                                  CharacterData.getDescription(
                                                                index,
                                                              )
                                                              .split('!')[0]
                                                              .length >
                                                          20
                                                      ? 20
                                                      : CharacterData.getDescription(
                                                        index,
                                                      ).split('!')[0].length,
                                                ) +
                                            '..!',
                                        style: const TextStyle(
                                          fontSize: 11, // 폰트 크기 줄임
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1, // 한 줄로 제한
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

                  const SizedBox(height: 16), // 간격 줄임
                  // 변경하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50, // 버튼 높이 줄임
                    child: ElevatedButton(
                      onPressed: () {
                        _updateUserCharacter(
                          context,
                          authProvider,
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
                          fontSize: 16, // 폰트 크기 줄임
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
