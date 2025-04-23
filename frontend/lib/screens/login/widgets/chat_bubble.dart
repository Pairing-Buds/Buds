import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Color color;
  final String text;
  final bool isLeft;
  final Color? backgroundColor;

  const ChatBubble({
    Key? key,
    required this.color,
    required this.text,
    required this.isLeft,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // color: backgroundColor ?? const Color(0xFFE0E0E0),
            color: backgroundColor ?? const Color.fromARGB(255, 253, 253, 253).withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 8, backgroundColor: color),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
