// Flutter imports:
import 'package:flutter/material.dart';

class LetterSenderFooter extends StatelessWidget {
  final String senderName;
  final String postPosition;

  const LetterSenderFooter({
    super.key,
    required this.senderName,
    required this.postPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        '$senderName$postPosition',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
