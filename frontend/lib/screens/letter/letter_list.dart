import 'package:flutter/material.dart';
import 'package:buds/screens/letter/letter_send.dart';

class LetterList extends StatelessWidget {
  const LetterList({super.key});

  @override
  Widget build(BuildContext context) {
    final titles = [
      '용감한 너구리',
      '행복한 오리',
      '배부른 개구리',
      '자상한 도마뱀',
      '친절한 여우',
      '귀여운 토끼',
      '위풍당당 너구리',
      '수줍은 펭귄',
    ];

    final dates = [
      '2025.04.21',
      '2025.04.20',
      '2025.04.19',
      '2025.04.18',
      '2025.04.17',
      '2025.04.16',
      '2025.04.15',
      '2025.04.14',
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 스크롤 가능한 편지 목록
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: titles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final isActive = index < 5;
                  final isSent = index == 2;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: isActive ? 1.0 : 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titles[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dates[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: isActive ? 1.0 : 0.3,
                        child: Image.asset(
                          isSent
                              ? 'assets/icons/sent.png'
                              : 'assets/icons/reply.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 하단 고정 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LetterSendScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6DCA7),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('익명의 편지 보내기'),
              ),
            ),

            // 하단 네비게이션 바와 겹치지 않게 여백 추가
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
