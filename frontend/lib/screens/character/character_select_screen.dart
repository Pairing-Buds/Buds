// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/screens/main_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';
import '../../services/auth_service.dart';
import 'widgets/character_selection_manager.dart';
import 'widgets/nickname_dialog.dart';
import 'package:buds/screens/survey/survey_screen.dart';
import 'package:buds/widgets/toast_bar.dart';

/// 캐릭터 선택 화면
class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int _currentPage = 1000;
  int? _flippedCardIndex;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Consumer<CharacterProvider>(
        builder: (context, characterProvider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                CharacterSelectionManager(
                  currentPage: _currentPage,
                  flippedCardIndex: _flippedCardIndex,
                  onPageChanged: _handlePageChanged,
                  onCardFlip: _handleCardFlip,
                  onCharacterSelect: _handleCharacterSelect,
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('캐릭터 선택', style: TextStyle(color: Colors.black)),
      centerTitle: true,
    );
  }

  Future<bool> _handleWillPop() async {
    if (_flippedCardIndex != null) {
      setState(() => _flippedCardIndex = null);
      return false;
    }
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    characterProvider.resetSelectedCharacter();
    return true;
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _handleCardFlip(int index) {
    setState(() {
      _flippedCardIndex = _flippedCardIndex == index ? null : index;
    });
  }

  void _handleCharacterSelect(int index) {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );
    characterProvider.selectCharacter(index);

    // 선택된 카드 인덱스 저장 (카드가 열린 상태 유지)
    setState(() => _flippedCardIndex = index);

    // 닉네임 선택 다이얼로그 표시
    _showNicknameDialog();
  }

  Future<void> _showNicknameDialog() async {
    final characterProvider = Provider.of<CharacterProvider>(
      context,
      listen: false,
    );

    // 첫 랜덤 닉네임 요청
    await characterProvider.requestRandomNickname();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NicknameDialog(
            initialNickname: characterProvider.nickname,
            onRefresh: () async {
              await characterProvider.requestRandomNickname();
              return characterProvider.nickname;
            },
            onConfirm: (nickname) {
              characterProvider.setNickname(nickname);
              _processCharacterSelection(
                nickname,
                characterProvider.selectedCharacterName!,
              );
            },
          ),
    );
  }

  Future<void> _processCharacterSelection(
    String nickname,
    String character,
  ) async {
    try {
      setState(() => _isProcessing = true);

      // 서버 전송 로직 제거 - SurveyScreen으로 데이터만 전달
      _showSelectionMessage(nickname, character);
      _navigateToSurveyScreen(nickname, character);
    } catch (e) {
      if (mounted) {
        Toast(
          context,
          '처리 중 오류가 발생했습니다: ${e.toString()}',
          icon: const Icon(Icons.error, color: Colors.red, size: 20),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSelectionMessage(String nickname, String character) {
    Toast(
      context,
      '${nickname}님, ${character}와(과) 함께하게 되었습니다!',
      icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
    );
  }

  void _navigateToSurveyScreen(String nickname, String character) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => SurveyScreen(
              selectedNickname: nickname,
              selectedCharacter: character,
            ),
      ),
    );
  }
}
