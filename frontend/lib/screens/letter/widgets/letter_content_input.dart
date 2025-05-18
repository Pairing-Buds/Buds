// Flutter imports:
import 'package:flutter/material.dart';

class LetterContentInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const LetterContentInput({
    super.key,
    required this.controller,
    this.hintText = '클릭하고 편지를 입력해보세요',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: MediaQuery.of(context).size.height * 0.4, // 최대 높이 제한
      child: TextField(
        controller: controller,
        expands: true,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.left,
      ),
    );
  }
}
