// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'character_card.dart';
import 'character_carousel.dart';
import 'character_info_overlay.dart';
import 'footer_text.dart';
import 'header_text.dart';
import 'page_indicator.dart';

/// 캐릭터 선택 화면의 메인 UI를 관리하는 위젯
class CharacterSelectionManager extends StatelessWidget {
  final int currentPage;
  final int? flippedCardIndex;
  final Function(int) onPageChanged;
  final Function(int) onCardFlip;
  final Function(int) onCharacterSelect;

  const CharacterSelectionManager({
    super.key,
    required this.currentPage,
    required this.flippedCardIndex,
    required this.onPageChanged,
    required this.onCardFlip,
    required this.onCharacterSelect,
  });

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
