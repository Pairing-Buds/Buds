import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:buds/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({Key? key, required this.onInitializationComplete})
    : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onInitializationComplete();
      }
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // AuthProvider 초기화
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      if (!mounted) return;

      // 애니메이션이 아직 완료되지 않았다면 애니메이션을 실행
      if (!_controller.isCompleted) {
        _controller.forward();
      }
    } catch (e) {
      debugPrint('앱 초기화 오류: $e');
      // 오류가 발생해도 스플래시 화면 완료 후 앱으로 진행
      if (!_controller.isCompleted) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로티 애니메이션 표시 (왼쪽에 패딩 적용)
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Lottie.asset(
              'assets/lotties/loading_animation.json',
              controller: _controller,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                // 애니메이션 길이를 컴포지션에 맞게 설정
                _controller.duration = composition.duration;
                // 애니메이션 시작
                _controller.forward();
              },
            ),
          ),
          const SizedBox(height: 24),
          // 텍스트는 중앙 정렬
          Center(
            child: Text(
              'Buds',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                // color: AppColors.primary,
                color: Colors.black,
                fontFamily: 'GmarketSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
