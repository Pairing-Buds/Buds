import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/letter/letter_reply.dart';
import 'package:buds/screens/letter/letter_send.dart';
import 'package:buds/services/letter_service.dart';

class LetterList extends StatelessWidget {
  const LetterList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Letter>>(
      future: LetterService().fetchLetters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final letters = snapshot.data ?? [];

        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(1, -1),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: letters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LetterReplyScreen(
                              letterId: letter.userId,
                              isScraped: false, // 기본값으로 시작
                            ),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  letter.userName,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  letter.lastLetterDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  letter.lastLetterStatus == "UNREAD" ? "읽지 않음" : "읽음",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: letter.lastLetterStatus == "UNREAD"
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            letter.received
                                ? 'assets/icons/letter/reply.png'
                                : 'assets/icons/letter/send.png',
                            width: 36,
                            height: 36,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('익명의 편지 보내기'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 10),
            ],
          ),
        );
      },
    );
  }
}