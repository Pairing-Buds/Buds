// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'character_card.dart';

/// 캐릭터 캐러셀 위젯
class CharacterCarousel extends StatefulWidget {
  final int currentPage;
  final int? flippedCardIndex;
  final Function(int) onPageChanged;
  final Function(int) onCardTap;
  final Function(int) onCardSelect;

  const CharacterCarousel({
    Key? key,
    required this.currentPage,
    required this.flippedCardIndex,
    required this.onPageChanged,
    required this.onCardTap,
    required this.onCardSelect,
  }) : super(key: key);

  @override
  State<CharacterCarousel> createState() => _CharacterCarouselState();
}

class _CharacterCarouselState extends State<CharacterCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 1000; // 충분히 큰 중간값

  @override
  void initState() {
    super.initState();
    _initPageController();
    _startAutoScroll();
  }

  void _initPageController() {
    _pageController = PageController(initialPage: _currentPage);
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && widget.flippedCardIndex == null) {
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
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        physics:
            widget.flippedCardIndex != null
                ? const NeverScrollableScrollPhysics()
                : null,
        itemBuilder: (context, index) {
          final characterIndex = index % 6; // 6개의 캐릭터를 반복
          final isFlipped = widget.flippedCardIndex == characterIndex;

          return FlippableCharacterCard(
            index: characterIndex,
            isFlipped: isFlipped,
            onTap: () => widget.onCardTap(characterIndex),
            onSelect: () => widget.onCardSelect(characterIndex),
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          widget.onPageChanged(index);
        },
      ),
    );
  }
}
