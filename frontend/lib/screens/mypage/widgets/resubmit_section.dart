import 'package:flutter/material.dart';

class ResubmitSection extends StatelessWidget {
  const ResubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 재설문조사 아이콘
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/resurvey');
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA255),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/resurvey_icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('재설문조사', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // 관심분야 변경 아이콘
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/retag');
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA255),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/retag_icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('관심분야 변경', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
