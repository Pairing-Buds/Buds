import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import 'package:buds/config/theme.dart';
import 'dart:async';
import 'widgets/character_widgets.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 3초마다 자동 스크롤하는 타이머 설정
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 6; // 6개의 캐릭터를 순환
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider 인스턴스를 한 번만 가져와서 사용
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    // WillPopScope를 사용하여 뒤로가기 버튼 처리
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 상태 초기화
        characterProvider.resetSelectedCharacter();
        return true; // true를 반환하여 뒤로가기 진행
      },
      child: Consumer<CharacterProvider>(
        builder: (context, characterProvider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('회원 가입', style: TextStyle(color: Colors.black)),
              centerTitle: true,
            ),
            body: Column(
              children: [
                // 노란색 구분선
                Container(
                  height: 10,
                  color: const Color(0xFFFAE3A0), // 파스텔 노란색
                ),

                const SizedBox(height: 40),

                // 안내 텍스트
                const HeaderText(),

                const SizedBox(height: 40),

                // 캐릭터 실루엣 무한 스크롤
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 6, // 캐릭터 개수 (6개)
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CharacterCard(
                        index: index,
                        onTap: () => _showCharacterBottomSheet(context, index),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 페이지 인디케이터
                PageIndicator(currentPage: _currentPage),

                const SizedBox(height: 20),

                // 안내 텍스트
                const FooterText(),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // 캐릭터 선택 바텀 시트 표시
  void _showCharacterBottomSheet(BuildContext context, int index) {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CharacterBottomSheet(
          index: index,
          onSelect: () {
            // 캐릭터 선택
            characterProvider.selectCharacter(index);

            // 바텀 시트 닫기
            Navigator.of(context).pop();

            // 선택 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('캐릭터 선택 완료'),
                backgroundColor: AppColors.primary,
              ),
            );

            // TODO: 다음 화면으로 이동 로직 추가
          },
        );
      },
    );
  }
}
