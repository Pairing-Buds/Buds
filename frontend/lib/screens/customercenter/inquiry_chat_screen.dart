import 'package:flutter/material.dart';

class InquiryChatScreen extends StatefulWidget {
  const InquiryChatScreen({Key? key}) : super(key: key);

  @override
  State<InquiryChatScreen> createState() => _InquiryChatScreenState();
}

class _InquiryChatScreenState extends State<InquiryChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'cs',
      content: '안녕하세요. 버즈 고객센터 입니다.',
      date: DateTime.now(),
    ),
    _ChatMessage(
      sender: 'cs',
      content: '궁금하신 점이나 문의 할 내역을 입력해 주시면 최대한 빠르게 답변 드리도록 하겠습니다! 감사합니다!',
      date: DateTime.now(),
    ),
    // 예시: 유저가 문의한 메시지
    // _ChatMessage(sender: 'user', content: '비밀번호를 못찾겠어요 ㅠㅠ', date: DateTime.now()),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(sender: 'user', content: text, date: DateTime.now()),
      );
      _controller.clear();
    });
    // TODO: 문의 생성 API 호출
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('문의 내역', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _messages.isNotEmpty ? _formatDate(_messages.first.date) : '',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? const Color(0xFFFFE0B2)
                              : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser) ...[
                          const Icon(
                            Icons.account_circle,
                            size: 28,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            msg.content,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 8),
                          // TODO: 캐릭터 이미지로 교체 가능
                          const Icon(
                            Icons.pets,
                            size: 28,
                            color: Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '문의 하기',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black87),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년${date.month.toString().padLeft(2, '0')}월${date.day.toString().padLeft(2, '0')}일';
  }
}

class _ChatMessage {
  final String sender; // 'user' or 'cs'
  final String content;
  final DateTime date;
  _ChatMessage({
    required this.sender,
    required this.content,
    required this.date,
  });
}
