// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/my_page_provider.dart';
import 'package:buds/services/step_counter_manager.dart';
import 'package:buds/screens/map/map_screen.dart';
import 'widgets/step_action_buttons.dart';
import 'widgets/step_info_widget.dart';

class StepDetailScreen extends StatefulWidget {
  const StepDetailScreen({super.key});

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  // 걸음 수 매니저
  final StepCounterManager _stepCounterManager = StepCounterManager();
  // 걸음 수 구독
  StreamSubscription<int>? _stepCountSubscription;
  // 서비스 상태 구독
  StreamSubscription<bool>? _serviceStatusSubscription;

  @override
  void initState() {
    super.initState();

    // 걸음 수 이벤트 구독
    _stepCountSubscription = _stepCounterManager.stepCountStream.listen(
      (steps) {
        // 마운트된 상태에서만 업데이트
        if (mounted) {
          // Provider에게 갱신 요청
          final myPageProvider = Provider.of<MyPageProvider>(
            context,
            listen: false,
          );
          myPageProvider.updateSteps(steps);
        }
      },
      onError: (error) {
        debugPrint('StepDetailScreen: 걸음 수 이벤트 오류 - $error');
      },
    );

    // 서비스 상태 구독
    _serviceStatusSubscription = _stepCounterManager.serviceStatusStream.listen(
      (isRunning) {
        if (mounted) {
          // Provider에게 갱신 요청
          final myPageProvider = Provider.of<MyPageProvider>(
            context,
            listen: false,
          );
          myPageProvider.updateServiceStatus(isRunning);
        }
      },
      onError: (error) {
        debugPrint('StepDetailScreen: 서비스 상태 이벤트 오류 - $error');
      },
    );

    // 초기 데이터 로딩
    _refreshStepCount();
  }

  @override
  void dispose() {
    // 구독 정리
    _stepCountSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    super.dispose();
  }

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
      debugPrint('StepDetailScreen: 걸음 수 새로고침 오류 - $e');
    }
  }

  // 지도 화면으로 이동
  void _navigateToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('만보기'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // 새로고침 버튼 추가
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStepCount,
            tooltip: '걸음 수 새로고침',
          ),
          // 지도 버튼 추가
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _navigateToMapScreen,
            tooltip: '지도 보기',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const StepInfoWidget(),
          const StepActionButtons(),
          // 지도 화면 이동 버튼 추가
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton.icon(
              onPressed: _navigateToMapScreen,
              icon: const Icon(Icons.directions_walk),
              label: const Text('주변 공원 찾기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
