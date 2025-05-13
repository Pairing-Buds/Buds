// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import '../models/character_data.dart';

/// 헤더 텍스트 위젯
class HeaderText extends StatelessWidget {
  const HeaderText({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: const [
          Text(
            '거주할 섬이 생성 되었습니다!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '함께 할 캐릭터를 선택해 주세요',
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 푸터 텍스트 위젯
class FooterText extends StatelessWidget {
  const FooterText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        '캐릭터는 마이페이지에서 변경 가능합니다!',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 페이지 인디케이터 위젯
class PageIndicator extends StatelessWidget {
  final int currentPage;

  const PageIndicator({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6, // 캐릭터 개수 (6개)
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentPage == index ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

/// 캐릭터 카드 앞면 위젯
class CharacterCardFront extends StatelessWidget {
  final int index;

  const CharacterCardFront({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 중앙에 이미지 배치
          Center(
            child: Image.asset(
              CharacterData.getImage(index),
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              color: Colors.black.withOpacity(0.95),
              colorBlendMode: BlendMode.srcATop,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person_outline,
                  size: 120,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 캐릭터 카드 뒷면 위젯
class CharacterCardBack extends StatelessWidget {
  final int index;
  final VoidCallback onSelect;

  const CharacterCardBack({
    Key? key,
    required this.index,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 중앙에 이미지 배치
          Center(
            child: Image.asset(
              CharacterData.getImage(index),
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 120,
                  color: AppColors.primary,
                );
              },
            ),
          ),

          // 하단에 정보 배치 (이미지 위에 오버레이)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CharacterInfoOverlay(index: index, onSelect: onSelect),
          ),
        ],
      ),
    );
  }
}

/// 캐릭터 정보 오버레이 위젯
class CharacterInfoOverlay extends StatelessWidget {
  final int index;
  final VoidCallback onSelect;

  const CharacterInfoOverlay({
    Key? key,
    required this.index,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 이름
          Text(
            CharacterData.getName(index),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // 캐릭터 설명
          Text(
            CharacterData.getDescription(index),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // 선택 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '이 캐릭터와 함께하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 플립 가능한 캐릭터 카드 위젯
class FlippableCharacterCard extends StatefulWidget {
  final int index;
  final bool isFlipped;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  const FlippableCharacterCard({
    Key? key,
    required this.index,
    required this.isFlipped,
    required this.onTap,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<FlippableCharacterCard> createState() => _FlippableCharacterCardState();
}

class _FlippableCharacterCardState extends State<FlippableCharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFrontSide = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      // 카드가 반쯤 뒤집혔을 때 앞/뒤 전환
      if (_animation.value > 0.5 && _showFrontSide) {
        setState(() {
          _showFrontSide = false;
        });
      } else if (_animation.value < 0.5 && !_showFrontSide) {
        setState(() {
          _showFrontSide = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FlippableCharacterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * pi;
            return Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 원근감 추가
                    ..rotateY(angle),
              alignment: Alignment.center,
              child:
                  _showFrontSide
                      ? CharacterCardFront(index: widget.index)
                      : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: CharacterCardBack(
                          index: widget.index,
                          onSelect: widget.onSelect,
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}

/// 기존 캐릭터 카드 위젯 (다른 곳에서 사용될 수 있음)
class CharacterCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const CharacterCard({Key? key, required this.index, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 캐릭터 이미지
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    CharacterData.getImage(index),
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    color: Colors.black.withOpacity(0.95),
                    colorBlendMode: BlendMode.srcATop,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_outline,
                        size: 120,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// 캐릭터 선택 관리 위젯
class CharacterSelectionManager extends StatelessWidget {
  final int currentPage;
  final int? flippedCardIndex;
  final Function(int) onPageChanged;
  final Function(int) onCardFlip;
  final Function(int) onCharacterSelect;

  const CharacterSelectionManager({
    Key? key,
    required this.currentPage,
    required this.flippedCardIndex,
    required this.onPageChanged,
    required this.onCardFlip,
    required this.onCharacterSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 10, color: const Color(0xFFFAE3A0)),
        const SizedBox(height: 40),
        const HeaderText(),
        const SizedBox(height: 20),
        CharacterCarousel(
          currentPage: currentPage,
          flippedCardIndex: flippedCardIndex,
          onPageChanged: onPageChanged,
          onCardTap: onCardFlip,
          onCardSelect: onCharacterSelect,
        ),
        const SizedBox(height: 20),
        PageIndicator(currentPage: currentPage % 6),
        const SizedBox(height: 20),
        const FooterText(),
        const SizedBox(height: 20),
      ],
    );
  }
}
