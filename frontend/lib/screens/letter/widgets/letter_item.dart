// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/models/letter_list_model.dart';
import 'package:buds/screens/letter/letter_detail_screen.dart';

class LetterItem extends StatelessWidget {
  final LetterModel letter;

  const LetterItem({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    final isUnread = letter.lastLetterStatus == "UNREAD";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => LetterDetailScreen(
                  opponentId: letter.userId,
                  opponentName: letter.userName,
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
                        letter.received && isUnread
                            ? Colors.black
                            : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  letter.lastLetterDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  letter.received
                      ? (isUnread ? "받은 편지: 읽지 않음" : "받은 편지: 읽음")
                      : "내가 보낸 편지",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        letter.received
                            ? (isUnread ? Colors.red : Colors.grey)
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
  }
}
