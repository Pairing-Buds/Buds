import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import 'package:buds/config/theme.dart';
import 'widgets/character_selection_manager.dart';
import 'package:buds/screens/main_screen.dart';

/// 캐릭터 선택 화면
class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int _currentPage = 1000;
  int? _flippedCardIndex;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Consumer<CharacterProvider>(
        builder: (context, characterProvider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: CharacterSelectionManager(
              currentPage: _currentPage,
              flippedCardIndex: _flippedCardIndex,
              onPageChanged: _handlePageChanged,
              onCardFlip: _handleCardFlip,
              onCharacterSelect: _handleCharacterSelect,
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

    setState(() => _flippedCardIndex = null);

    _showSelectionMessage(characterProvider);
    _navigateToMainScreen();
  }

  void _showSelectionMessage(CharacterProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.getSelectionMessage()),
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
