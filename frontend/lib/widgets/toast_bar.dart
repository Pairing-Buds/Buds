// Flutter imports:
import 'package:flutter/material.dart';

void Toast(BuildContext context, String message, {Widget? icon}) {
  icon ??= const Icon(Icons.check_circle, color: Colors.white, size: 20);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFA9A9A9),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      duration: const Duration(seconds: 2),
    ),
  );
}
