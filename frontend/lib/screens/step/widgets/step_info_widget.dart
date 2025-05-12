// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../providers/my_page_provider.dart';
import '../../../services/step_counter_manager.dart';

class StepInfoWidget extends StatefulWidget {
  const StepInfoWidget({Key? key}) : super(key: key);

  @override
  State<StepInfoWidget> createState() => _StepInfoWidgetState();
}

class _StepInfoWidgetState extends State<StepInfoWidget> {
  // 걸음 수 매니저
  final StepCounterManager _stepCounterManager = StepCounterManager();

  // 걸음 수 새로고침
  Future<void> _refreshStepCount() async {
    try {
      // 걸음 수 직접 가져오기
      final steps = await _stepCounterManager.getCurrentSteps();
      
      if (mounted) {
        // Provider에게 갱신 요청
        final myPageProvider = Provider.of<MyPageProvider>(
          context,
          listen: false,
        );
        myPageProvider.updateSteps(steps);
      }
    } catch (e) {
      debugPrint('StepInfoWidget: 걸음 수 새로고침 오류 - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // MyPageProvider에서 최신 데이터 가져오기
    final myPageProvider = Provider.of<MyPageProvider>(context);
    final currentSteps = myPageProvider.currentSteps;
    final goalSteps = myPageProvider.targetSteps;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F4EA),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '목표 걸음',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const Spacer(),
                const Text(
                  '현재',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${goalSteps.toString()} 보',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${currentSteps.toString()} 보',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            // 새로고침 버튼 추가
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _refreshStepCount,
                tooltip: '걸음 수 새로고침',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
