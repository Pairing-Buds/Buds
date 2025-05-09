import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'voice_chatting_screen.dart';
import 'chat_detail_screen.dart';

class StartChattingScreen extends StatefulWidget {
  const StartChattingScreen({super.key});

  @override
  State<StartChattingScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartChattingScreen> {
  final TextEditingController _controller = TextEditingController();

  void _handleSendOrVoice() {
    FocusScope.of(context).unfocus(); // 키보드 닫기

    final input = _controller.text.trim();

    if (input.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VoiceChattingScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(initialText: input),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: const CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Opacity(
            opacity: 0.5,
            child: Image.asset('assets/images/marmet_head.png', width: 240),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: '답장하기',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                suffixIcon: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _handleSendOrVoice();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Image.asset('assets/icons/chat.png', width: 30),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
