// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/screens/activity/shell_screen.dart';
import 'package:buds/screens/chat/chat_detail_screen.dart';
import 'package:buds/screens/home/widgets/speech_bubble.dart';
import 'package:buds/screens/home/latest_letter_screen.dart';
import 'package:buds/screens/survey/survey_screen.dart';
import 'package:buds/screens/mypage/widgets/wake_up_section.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/screens/login/onboarding_screen.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/character/models/character_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen(),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/main_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 태양 아이콘
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // 태양 아이콘을 눌렀을 때 기상 시간 알림 설정 바텀시트 열기
                _showTimePickerBottomSheet(context);
              },
              child: Image.asset(
                'assets/icons/sun.png',
                width: 120,
                height: 120,
              ),
            ),
          ),

          // // 음악 on/off 아이콘
          // Positioned(
          //   top: 50,
          //   right: 20,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const SurveyScreen()),
          //       );
          //     },
          //     child: Image.asset(
          //       'assets/icons/survey_icon.png',
          //       width: 40,
          //       height: 40,
          //     ),
          //   ),
          // ),

          // 캐릭터 이미지
          Positioned(
            top: MediaQuery.of(context).size.height * 0.44,
            left: MediaQuery.of(context).size.width * 0.5 - 75,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final userCharacter = authProvider.userData?['userCharacter'];
                int characterIndex = getCharacterIndex(userCharacter);
                
                if (kDebugMode) {
                  print('홈화면: 사용자 캐릭터: $userCharacter, 인덱스: $characterIndex');
                }
                
                return Image.asset(
                  CharacterData.getImage(characterIndex),
                  width: 150,
                  height: 150,
                );
              },
            ),
          ),

          // 말풍선 위젯
          const SpeechBubbleScreen(),

          // 조개 아이콘
          Positioned(
            top: MediaQuery.of(context).size.height * 0.575,
            left: 40,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShellScreen()),
                );
              },
              child: Image.asset(
                'assets/icons/shell.png',
                width: 80,
                height: 80,
              ),
            ),
          ),

          // 편지 아이콘
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15 - 100,
            left: 190,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LastLetterScreen(),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/icons/bottle_letter.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기상 시간 설정 바텀시트 표시 메서드
  void _showTimePickerBottomSheet(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context, listen: false);
    TimeOfDay selectedTime = myPageProvider.wakeUpTime; // 현재 저장된 시간 가져오기

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/sun.png',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '기상 시간 설정',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TimePickerSpinner(
                      time: selectedTime,
                      onTimeChange: (time) {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 선택한 시간을 프로바이더에 저장
                        myPageProvider.wakeUpTime = selectedTime;

                        // 바텀 시트 닫기
                        Navigator.pop(context);

                        // WakeUpSection의 static 알람 설정 함수 호출
                        WakeUpSection.setWakeUpAlarm(context, selectedTime);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  // 서버 캐릭터 이름을 인덱스로 변환 (Character 섹션과 동일한 로직)
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
}
