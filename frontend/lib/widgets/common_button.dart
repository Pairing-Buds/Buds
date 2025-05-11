import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double widthRatio;
  final double height;

  const CommonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.widthRatio = 0.45,
    this.height = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = width ?? (screenWidth * widthRatio);

    return SizedBox(
      width: buttonWidth,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

