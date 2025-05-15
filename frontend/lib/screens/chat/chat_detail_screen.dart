// ChatDetailScreen.dart (voice + text 통합)

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/screens/chat/voice_chatting_screen.dart';
import 'package:buds/screens/chat/widgets/typing_indicator.dart';
import 'package:buds/services/chat_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/providers/auth_provider.dart';


class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isWaitingForBot = false;
  bool _hasStarted = false;
  late stt.SpeechToText _speech;

  static const String loadingMessage = 'LOADING';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final history = await _chatService.getChatHistory();

    history.sort((a, b) {
      final timeA = DateTime.parse(a['created_at']);
      final timeB = DateTime.parse(b['created_at']);
      return timeA.compareTo(timeB);
    });

    setState(() {
      _chatHistory = history;
      _hasStarted = history.isNotEmpty;
    });

    _scrollToBottom();
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _hasStarted = true;
      _chatHistory.add({
        'message': userMessage,
        'is_user': true,
        'created_at': DateTime.now().toIso8601String(),
      });
      _isWaitingForBot = true;
      _chatHistory.add({
        'message': loadingMessage,
        'is_user': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _controller.clear();
    });

    _scrollToBottom();

    final botMessage = await _chatService.sendMessage(
      message: userMessage,
      isVoice: false,
    );

    setState(() {
      _chatHistory.removeLast();
      _chatHistory.add({
        'message': botMessage,
        'is_user': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _isWaitingForBot = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userCharacter = authProvider.userData?['userCharacter'] ?? '마멋';

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: userCharacter,
        showBackButton: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _hasStarted ? _buildChatView() : _buildStartView(),
      ),
    );
  }


  Widget _buildStartView() {
    return Column(
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
                  final input = _controller.text.trim();
                  if (input.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceChattingScreen()),
                    );
                  } else {
                    _handleSend();
                  }
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
    );
  }

  Widget _buildChatView() {
    final latestDate = _chatHistory.isNotEmpty && _chatHistory.last['created_at'] != null
        ? DateFormat('yyyy년 M월 d일').format(DateTime.parse(_chatHistory.last['created_at']))
        : '';

    return Column(
      children: [
        if (latestDate.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(latestDate),
                ),
                const Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
              ],
            ),
          ),
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final chat = _chatHistory[index];
                return _buildChatBubble(
                  chat['message'],
                  isBot: !(chat['is_user'] ?? false),
                  createdAt: chat['created_at'],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                  final input = _controller.text.trim();
                  if (input.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceChattingScreen()),
                    );
                  } else {
                    _handleSend();
                  }
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
        )
      ],
    );
  }

  Widget _buildChatBubble(String text, {required bool isBot,
    required String createdAt,}) {
    if (text == loadingMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Image(
                image: AssetImage('assets/images/marmet_head.png'),
                width: 28,
                height: 28,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.44),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const TypingIndicator(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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