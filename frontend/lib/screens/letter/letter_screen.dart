import 'package:flutter/material.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/screens/letter/letter_list.dart';

class LetterScreen extends StatelessWidget {
  const LetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // 퀘스트 배너
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F7F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '오늘의 퀘스트를 완료하고\n편지지를 모아봐요',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 15), // y값 증가 → 아래로 이동
                  child: Image.asset(
                    'assets/images/marmet_cutting_head.png',
                    width: 80,
                    height: 60,
                  ),
                ),
              ],
            ),
          ),

          // 탭 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text(
                  '편지 목록',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Spacer(),
                Text(
                  '나의 편지 15',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 편지 목록 컴포넌트
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LetterList(), // ← 여기에 추가
            ),
          ),
        ],
      ),
    );
  }
}
