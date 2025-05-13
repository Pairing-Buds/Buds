// Flutter imports:
import 'package:flutter/material.dart';

/// 채팅 버블 위젯
class ChatBubble extends StatelessWidget {
  final Color color;
  final String text;
  final bool isLeft;
  final Color? backgroundColor;
  final String? iconPath;

  const ChatBubble({
    super.key,
    required this.color,
    required this.text,
    required this.isLeft,
    this.backgroundColor,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                const Color.fromARGB(255, 253, 253, 253).withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(iconPath!, width: 24, height: 24),
                )
              else
                CircleAvatar(radius: 8, backgroundColor: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
