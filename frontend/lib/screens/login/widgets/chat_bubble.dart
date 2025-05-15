// Flutter imports:
import 'package:flutter/material.dart';

/// 채팅 버블 위젯
class ChatBubble extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLeft;
  final String iconPath;
  final Color? backgroundColor;

  const ChatBubble({
    super.key,
    required this.text,
    required this.color,
    required this.isLeft,
    required this.iconPath,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLeft) _buildProfileImage(),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isLeft ? Colors.white : color.withOpacity(0.2)),
              borderRadius: BorderRadius.only(
                topLeft:
                    isLeft
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                topRight:
                    isLeft
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isLeft ? Colors.black87 : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!isLeft) _buildProfileImage(),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
        image: DecorationImage(image: AssetImage(iconPath), fit: BoxFit.cover),
      ),
    );
  }
}
