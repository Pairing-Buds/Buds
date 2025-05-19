import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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

  // 무한 스크롤 관련 변수
  int _offset = 0;
  final int _limit = 30;
  bool _hasMore = true;
  bool _isLoading = false;

  static const String loadingMessage = 'LOADING';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadMoreChat();
    _scrollController.addListener(_onScroll);
  }

  String _getCharacterIcon(String characterName) {
    switch (characterName) {
      case '마멋':
        return 'assets/icons/characters/marmeticon.png';
      case '고양이':
        return 'assets/icons/characters/foxicon.png';
      case '개구리':
        return 'assets/icons/characters/frogicon.png';
      case '게코':
        return 'assets/icons/characters/lizardicon.png';
      case '오리':
        return 'assets/icons/characters/duckicon.png';
      case '토끼':
        return 'assets/icons/characters/rabbiticon.png';
      default:
        return 'assets/icons/characters/marmeticon.png';
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      return true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshChatHistory(); // 아래 함수 정의
    });
  }

  Future<void> _refreshChatHistory() async {
    _offset = 0;
    _hasMore = true;
    _chatHistory.clear();
    await _loadMoreChat();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent + 100 && !_isLoading) {
      _loadMoreChat();
    }
  }

  Future<void> _loadMoreChat() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    final result = await _chatService.getChatHistory(offset: _offset, limit: _limit);
    final List<Map<String, dynamic>> newMessages = result['messages'];
    final nextOffset = result['nextOffset'];
    final hasMore = result['hasMore'];

    newMessages.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));

    setState(() {
      _chatHistory.insertAll(0, newMessages);
      _offset = nextOffset ?? _offset;
      _hasMore = hasMore ?? false;
      _hasStarted = _chatHistory.isNotEmpty;
      _isLoading = false;
    });
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
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userCharacter = authProvider.userData?['userCharacter'] ?? '마멋';
    final characterIconPath = _getCharacterIcon(userCharacter);

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: userCharacter,
        showBackButton: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _hasStarted ? _buildChatView() : _buildStartView(characterIconPath),
      ),
    );
  }

  Widget _buildStartView(String  characterIconPath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Opacity(
          opacity: 0.5,
          child: Image.asset(characterIconPath, width: 240),
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
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels <= scrollInfo.metrics.minScrollExtent + 50 && !_isLoading) {
                _loadMoreChat();
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              reverse: true,
              itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _chatHistory.length - 1 - index;
                  final chat = _chatHistory[reversedIndex];
                  final createdAt = DateTime.parse(chat['created_at']).add(const Duration(hours: 9));
                  final isBot = !(chat['is_user'] ?? false);

                  // 날짜 구분선 판단
                  bool showDateHeader = false;
                  final currentDate = DateFormat('yyyy년 M월 d일').format(createdAt);

                  if (reversedIndex == 0) {
                    showDateHeader = true;
                  } else {
                    final prevChat = _chatHistory[reversedIndex - 1];
                    final prevDate = DateFormat('yyyy년 M월 d일')
                        .format(DateTime.parse(prevChat['created_at']).add(const Duration(hours: 9)));
                    if (currentDate != prevDate) {
                      showDateHeader = true;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                          child: Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(currentDate, style: const TextStyle(color: Colors.black54)),
                              ),
                              const Expanded(child: Divider(color: Colors.black, thickness: 0.5)),
                            ],
                          ),
                        ),
                      _buildChatBubble(chat['message'], isBot: isBot, createdAt: chat['created_at']),
                    ],
                  );
                }
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextInputField(),
      ],
    );
  }


  Widget _buildTextInputField() {
    return Padding(
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
    );
  }


  Widget _buildChatBubble(String text, {
    required bool isBot,
    required String createdAt,
  }) {
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

    final utcTime = DateTime.parse(createdAt);
    final kstTime = utcTime.add(const Duration(hours: 9));
    final timeText = DateFormat('a h:mm', 'ko').format(kstTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isBot)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.asset(
                    _getCharacterIcon(
                      Provider.of<AuthProvider>(context, listen: false).userData?['userCharacter'] ?? '마멋',
                    ),
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
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 36, right: 8),
            child: Text(
              timeText,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}