import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'dart:math';
import '../models/character_data.dart';
import 'character_info_overlay.dart';

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
      if (_animation.value > 0.5 && _showFrontSide) {
        setState(() => _showFrontSide = false);
      } else if (_animation.value < 0.5 && !_showFrontSide) {
        setState(() => _showFrontSide = true);
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
                    ..setEntry(3, 2, 0.001)
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
