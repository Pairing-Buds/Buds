import 'package:flutter/material.dart';

class LetterSendScreen extends StatelessWidget {
  const LetterSendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'letter_screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}