// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_response_model.dart';
import 'package:buds/screens/letter/letter_detail_screen.dart';
import 'package:buds/services/letter_service.dart';

// import 'package:buds/models/letter_list_model.dart';

class LetterList extends StatefulWidget {
  final Function(int) onCountFetched;
  final VoidCallback onWritePressed;

  const LetterList({
    super.key,
    required this.onCountFetched,
    required this.onWritePressed,
  });

  @override
  State<LetterList> createState() => _LetterListState();
}

class _LetterListState extends State<LetterList> {
  bool _countReported = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LetterResponseModel>(
      future: LetterService().fetchLetters(), // LetterResponseModel로 변경
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }

        final letterResponse = snapshot.data;
        final letters = letterResponse?.letters ?? [];

        if (!_countReported && letterResponse != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCountFetched(letterResponse.letterCnt);
            _countReported = true;
          });
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                    final isUnread = letter.lastLetterStatus == "UNREAD";

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => LetterDetailScreen(
                                  opponentId: letter.userId, // 상대방 사용자 ID
                                  opponentName: letter.userName, // 상대방 사용자 이름
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isUnread ? Colors.black : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                  // 받은 편지: "읽지 않음" 또는 "읽음"으로 상태 표시
                                  // 보낸 편지: 항상 "보낸 편지"로 표시
                                  letter.received
                                      ? (isUnread
                                          ? "받은 편지: 읽지 않음"
                                          : "받은 편지: 읽음")
                                      : "내가 보낸 편지",
                                  style: TextStyle(
                                    fontSize: 12,
                                    // 받은 편지: 읽지 않음은 빨간색, 읽음은 회색
                                    // 보낸 편지: 항상 회색
                                    color:
                                        letter.received
                                            ? (isUnread
                                                ? Colors.red
                                                : Colors.grey)
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            letter.received
                                ? 'assets/icons/letter/receive_letter_icon.png'
                                : 'assets/icons/letter/send_letter_icon.png',
                            width: 50,
                            height: 50,
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
                  onPressed: widget.onWritePressed,
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
