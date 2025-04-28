import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/diary/diary_detail_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String message;

  const ChatDetailScreen({super.key, required this.message});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        print('보낸 메시지: ${_controller.text}');
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sideMargin = screenWidth * 0.11;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideMargin),
              child: Row(
                children: const [
                  Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '2025년 4월 20일',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildChatBubble('오늘은 힘든 하루였구나.\n나랑 더 얘기해볼래?', isBot: true),
            _buildChatBubble(widget.message, isBot: false),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiaryDetailScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        'assets/icons/chat.png',
                        width: 30,
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, {required bool isBot}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset(
                'assets/images/marmet_head.png',
                width: 28,
                height: 28,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? AppColors.primary.withOpacity(0.44) : AppColors.primary,
                borderRadius: isBot
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
                    : const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
