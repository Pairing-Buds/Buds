import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동 화면'),
      ),
      body: const Center(
        child: Text(
          '여기는 ActivityScreen입니다',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
