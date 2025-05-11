import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:buds/config/theme.dart';
import 'widgets/character_selection_manager.dart';
import 'package:buds/screens/main_screen.dart';
import 'widgets/nickname_dialog.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';

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
    // 이제 단일 경로만 있음 - 로그인된 사용자의 캐릭터/닉네임 설정
    try {
      setState(() => _isProcessing = true);
      final authService = DioAuthService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (kDebugMode) {
        print('캐릭터/닉네임 설정 시도: nickname=$nickname, character=$character');
      }

      // 1. 캐릭터/닉네임 정보 서버에 전송
      final completeResult = await authService.completeSignUp(
        nickname,
        character,
      );

      if (kDebugMode) {
        print('캐릭터/닉네임 설정 결과: $completeResult');
      }

      // 2. 사용자 정보 새로고침 (업데이트된 정보 가져오기)
      await authProvider.refreshUserData();

      if (kDebugMode) {
        print('사용자 정보 새로고침 완료: ${authProvider.userData?['name'] ?? '정보 없음'}');
      }

      _showSelectionMessage(nickname, character);
      _navigateToMainScreen();
    } catch (e) {
      if (kDebugMode) {
        print('캐릭터/닉네임 설정 오류: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('캐릭터/닉네임 설정 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSelectionMessage(String nickname, String character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${nickname}님, ${character}와(과) 함께하게 되었습니다!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }
}
