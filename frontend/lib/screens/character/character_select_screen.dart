import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import 'package:buds/config/theme.dart';
import 'dart:async';
import 'widgets/character_widgets.dart';
import 'models/character_data.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 1000; // 충분히 큰 중간값
  int? _flippedCardIndex;

  @override
  void initState() {
    super.initState();
    _initPageController();
    _startAutoScroll();
  }

  void _initPageController() {
    // 가운데 페이지부터 시작하도록 설정
    _pageController = PageController(initialPage: _currentPage);
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _flippedCardIndex == null) {
        _currentPage++;
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
        if (_flippedCardIndex != null) {
          setState(() {
            _flippedCardIndex = null;
          });
          return false;
        }
        // 뒤로가기 시 상태 초기화
        characterProvider.resetSelectedCharacter();
        return true; // true를 반환하여 뒤로가기 진행
      },
      child: Consumer<CharacterProvider>(
        builder: (context, characterProvider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: _buildBody(),
          );
        },
      ),
    );
  }

  // 앱바 위젯
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('캐릭터 선택', style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }

  // 본문 위젯
  Widget _buildBody() {
    return Column(
      children: [
        // 노란색 구분선
        Container(
          height: 10,
          color: const Color(0xFFFAE3A0), // 파스텔 노란색
        ),

        const SizedBox(height: 40),

        // 안내 텍스트
        const HeaderText(),

        const SizedBox(height: 20),

        // 캐릭터 캐러셀
        _buildCharacterCarousel(),

        const SizedBox(height: 20),

        // 페이지 인디케이터
        PageIndicator(currentPage: _currentPage % 6),

        const SizedBox(height: 20),

        // 안내 텍스트
        const FooterText(),

        const SizedBox(height: 20),
      ],
    );
  }

  // 캐릭터 캐러셀 위젯
  Widget _buildCharacterCarousel() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        physics:
            _flippedCardIndex != null
                ? const NeverScrollableScrollPhysics()
                : null,
        itemBuilder: (context, index) {
          final characterIndex = index % 6; // 6개의 캐릭터를 반복
          final isFlipped = _flippedCardIndex == characterIndex;

          return FlippableCharacterCard(
            index: characterIndex,
            isFlipped: isFlipped,
            onTap: () => _toggleCardFlip(characterIndex),
            onSelect: () => _selectCharacter(characterIndex),
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }

  // 카드 뒤집기 토글
  void _toggleCardFlip(int index) {
    setState(() {
      if (_flippedCardIndex == index) {
        _flippedCardIndex = null;
      } else {
        _flippedCardIndex = index;
      }
    });
  }

  // 캐릭터 선택
  void _selectCharacter(int index) {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    // 캐릭터 선택
    characterProvider.selectCharacter(index);

    // 카드 뒤집기 초기화
    setState(() {
      _flippedCardIndex = null;
    });

    // 선택 메시지 표시
    _showSelectionMessage(index);

    // TODO: 다음 화면으로 이동 로직 추가
  }

  // 선택 메시지 표시
  void _showSelectionMessage(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${CharacterData.getName(index)}와(과) 함께하게 되었습니다!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
