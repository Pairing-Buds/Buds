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
                            Image.asset(
                              CharacterData.getMyPageImage(characterIndex),
                              width: 100,
                              height: 100,
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
}
