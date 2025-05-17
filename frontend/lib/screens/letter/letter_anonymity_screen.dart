// Flutter imports:
import 'package:flutter/material.dart';
// import 'dart:math';
// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/screens/letter/widgets/letter_anonymity_toggle.dart';
import 'package:buds/screens/letter/widgets/letter_content_card.dart';
import 'package:buds/screens/letter/widgets/letter_send_button.dart';
import 'package:buds/widgets/toast_bar.dart';

class LetterAnonymityScreen extends StatefulWidget {
  const LetterAnonymityScreen({Key? key}) : super(key: key);

  @override
  State<LetterAnonymityScreen> createState() => _LetterAnonymityScreenState();
}

class _LetterAnonymityScreenState extends State<LetterAnonymityScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 로그인한 사용자 닉네임 가져오기
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final letterProvider = Provider.of<LetterProvider>(context);
    final userName = authProvider.userData?['name'] ?? '익명 사용자';
    String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 오버플로우 방지
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // 익명/랜덤 토글
            LetterAnonymityToggle(provider: letterProvider),

            // 편지 내용 입력 카드
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LetterContentCard(
                  controller: _controller,
                  title: '익명의 누군가에게',
                  date: today,
                  fromName: userName,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 전송 버튼
            LetterSendButton(
              isLoading: letterProvider.isSending,
              onTap: () => _sendLetter(letterProvider),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _sendLetter(LetterProvider provider) async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('편지 내용을 입력해주세요')));
      return;
    }

    final success = await provider.sendAnonymityLetter(content);

    if (success) {
      Toast(
        context,
        '편지를 성공적으로 보냈습니다',
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
      _controller.clear();
      Navigator.pushReplacementNamed(context, '/letter');
    } else {
      Toast(
        context,
        '편지 전송에 실패했습니다',
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}

