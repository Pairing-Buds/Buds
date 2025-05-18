// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';

class LetterSendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const LetterSendButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: 140,
          height: 44,
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey : AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      '편지보내기',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
          ),
        ),
      ),
    );
  }
}
