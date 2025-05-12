import 'package:flutter/material.dart';
import '../../models/inquiry.dart';
import '../../services/inquiry_service.dart';

class InquiryChatScreen extends StatefulWidget {
  const InquiryChatScreen({Key? key}) : super(key: key);

  @override
  State<InquiryChatScreen> createState() => _InquiryChatScreenState();
}

class _InquiryChatScreenState extends State<InquiryChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_ChatMessage> _messages = [];
  InquiryResponse? _inquiryResponse;

  @override
  void initState() {
    super.initState();
    _loadInquiries();
  }

  void _loadInquiries() async {
    final inquiryService = DioInquiryService();
    final response = await inquiryService.fetchInquiries();
    
    if (response == null) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문의 내역을 불러오는데 실패했습니다.')),
        );
      }
      return;
    }

    _inquiryResponse = response;

    final messages = <_ChatMessage>[];

    // 초기 환영 메시지
    messages.add(
      _ChatMessage(
        sender: 'cs',
        content: '안녕하세요. 버즈 고객센터 입니다.',
        date: DateTime.now(),
      ),
    );

    messages.add(
      _ChatMessage(
        sender: 'cs',
        content: '궁금하신 점이나 문의 할 내역을 입력해 주시면 최대한 빠르게 답변 드리도록 하겠습니다! 감사합니다!',
        date: DateTime.now(),
      ),
    );

    // 기존 문의 내역을 채팅 메시지로 변환
    for (var question in response.resMsg.questions) {
      messages.add(
        _ChatMessage(
          sender: 'user',
          content: '${question.subject}\n\n${question.content}',
          date: DateTime.parse(question.createdAt.replaceAll(' ', 'T')),
        ),
      );

      if (question.answer != null) {
        messages.add(
          _ChatMessage(
            sender: 'cs',
            content: question.answer!.content,
            date: DateTime.parse(
              question.answer!.createdAt.replaceAll(' ', 'T'),
            ),
          ),
        );
      }
    }

    // 날짜순으로 정렬
    messages.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _messages = messages;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    setState(() {
      _messages.add(_ChatMessage(sender: 'user', content: text, date: now));
      _controller.clear();
    });

    final inquiryService = DioInquiryService();
    final success = await inquiryService.createInquiry('문의', text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의 전송에 실패했습니다.')),
      );
    } else {
      // 문의 전송 성공 후 목록 새로고침
      _loadInquiries();
    }
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';

                // 날짜 표시 로직
                bool showDate = true;
                if (index > 0) {
                  final prevMsg = _messages[index - 1];
                  showDate = !_isSameDay(prevMsg.date, msg.date);
                }

                return Column(
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _formatDate(msg.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? const Color(0xFFFFE0B2)
                                  : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '문의 내용을 입력해주세요',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

class _ChatMessage {
  final String sender;
  final String content;
  final DateTime date;

  _ChatMessage({
    required this.sender,
    required this.content,
    required this.date,
  });
}
