import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/my_page_provider.dart';

/// 걸음 수 섹션 위젯
class StepSection extends StatelessWidget {
  const StepSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '걸음 수',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.blue.shade400,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${myPageProvider.currentSteps} 걸음',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '목표: ${myPageProvider.targetSteps} 걸음',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              CircularProgressIndicator(
                value: myPageProvider.stepAchievementRate,
                backgroundColor: Colors.blue.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
