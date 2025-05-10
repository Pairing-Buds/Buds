import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/faq_section.dart';
import '../../providers/auth_provider.dart';
import '../character/models/character_data.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userCharacter = authProvider.userData?['userCharacter'] ?? '';
    int characterIndex = 0;
    for (int i = 0; i < CharacterData.characterCount; i++) {
      if (CharacterData.getName(i) == userCharacter) {
        characterIndex = i;
        break;
      }
    }
    final characterImagePath = CharacterData.getMyPageImage(characterIndex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('자주 묻는 질문', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FaqSection(characterImagePath: characterImagePath),
          ),
        ),
      ),
    );
  }
}
