// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/providers/letter_provider.dart';

class LetterDetailHeader extends StatelessWidget {
  final bool isReceived;
  final int letterId;
  final int letterNumber;

  const LetterDetailHeader({
    super.key,
    required this.isReceived,
    required this.letterId,
    required this.letterNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Text(
            (isReceived ? '보낸 편지' : '받은 편지'),
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const Spacer(),
          Text(
            '$letterNumber번째 편지',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
