// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_content_model.dart';

class LetterContentView extends StatelessWidget {
  final LetterContentModel letter;
  final String recipientName;
  final String recipientPostPosition;
  final String senderPostPosition;

  const LetterContentView({
    super.key,
    required this.letter,
    required this.recipientName,
    required this.recipientPostPosition,
    required this.senderPostPosition,
  });

  @override
  Widget build(BuildContext context) {
    final isReceived = letter.receiverName == recipientName;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.letterBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 (To: / 아이콘)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isReceived
                    ? '$recipientName$recipientPostPosition'
                    : '${letter.receiverName}$recipientPostPosition',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 10),
              Image.asset(
                isReceived
                    ? 'assets/icons/letter/receive_letter_icon.png'
                    : 'assets/icons/letter/send_letter_icon.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '작성일: ${letter.createdAt}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                letter.content,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${letter.senderName}$senderPostPosition',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
