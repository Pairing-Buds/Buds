import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buds/screens/login/login_main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _navigationInProgress = false; // 네비게이션 중복 방지 플래그

  @override
  void initState() {
    super.initState();
  }

  // WillPopScope 콜백 - 뒤로가기 버튼 처리
  Future<bool> _onWillPop() async {
    // 온보딩 화면에서 뒤로가기를 누르면 앱 종료 (또는 다른 정책 구현)
    return false; // false를 반환하면 뒤로가기가 무시됨
  }

  // 온보딩 완료 처리 함수
  Future<void> _completeOnboarding() async {
    // 이미 네비게이션이 진행 중이면 중복 실행 방지
    if (_navigationInProgress) {
      return;
    }
    // 네비게이션 시작 표시
    setState(() {
      _navigationInProgress = true;
    });

    try {
      // 온보딩 완료 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('completed_onboarding', true);

      // if (mounted) {
      //   Navigator.pushReplacementNamed(context, '/');
      // }

      if (mounted) {
        // 로그인 화면으로 교체 (이전 화면으로 돌아갈 수 없음)
        // 네비게이션 스택을 완전히 초기화하고 새로운 스택 시작
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginMainScreen()),
          (route) => false, // 모든 이전 라우트 제거
        );
      }
    } catch (e) {
      debugPrint('온보딩 완료 저장 오류: $e');
      // 오류 발생 시 네비게이션 플래그 초기화
      if (mounted) {
        setState(() {
          _navigationInProgress = false;
        });
      }
    }
  }

  // 다음 페이지로 이동하는 함수
  void _nextPage() {
    if (_currentPage < 3) {
      // 총 4개 페이지 (인덱스 0부터 시작)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // 마지막 페이지에서는 온보딩 완료 처리
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 페이지 뷰 (온보딩 이미지)
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: List.generate(
              4,
              (index) => Image.asset(
                'assets/onboarding/onboarding_${index + 1}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 다음 페이지로 이동하는 버튼
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: GestureDetector(
              onTap: _nextPage, // 탭하면 다음 페이지로
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
