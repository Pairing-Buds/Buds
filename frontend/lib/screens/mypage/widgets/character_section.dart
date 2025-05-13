// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/my_page_provider.dart';

/// 캐릭터 섹션 위젯
class CharacterSection extends StatelessWidget {
  const CharacterSection({super.key});


  @override
  Widget build(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            '나의 캐릭터',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Image.asset(
            myPageProvider.selectedCharacterImage,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            myPageProvider.selectedCharacterName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStepCounter(myPageProvider),
        ],
      ),
    );
  }

  Widget _buildStepCounter(MyPageProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('목표 걸음', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text(
                '6,000 보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('현재', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                provider.formatSteps(provider.currentSteps),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
