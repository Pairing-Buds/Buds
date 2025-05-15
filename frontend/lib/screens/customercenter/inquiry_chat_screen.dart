// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/models/inquiry.dart';
import 'package:buds/services/inquiry_service.dart';
import 'package:buds/widgets/toast_bar.dart';

class InquiryChatScreen extends StatefulWidget {
  const InquiryChatScreen({super.key});

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
        Toast(context, '문의 내역을 불러오는데 실패했습니다.');
      }
      return;
    }

    _inquiryResponse = response;

    final messages = <_ChatMessage>[];

    // 초기 환영 메시지
    // messages.add(
    //   _ChatMessage(
    //     sender: 'cs',
    //     content: '안녕하세요. 버즈 고객센터 입니다.',
    //     date: DateTime.now().subtract(const Duration(minutes: 5)),
    //   ),
    // );

    // messages.add(
    //   _ChatMessage(
    //     sender: 'cs',
    //     content: '궁금하신 점이나 문의 할 내역을 입력해 주시면 최대한 빠르게 답변 드리도록 하겠습니다! 감사합니다!',
    //     date: DateTime.now().subtract(const Duration(minutes: 4)),
    //   ),
    // );

    // 질문-답변 쌍으로 정렬하기 위한 맵
    final Map<int, List<_ChatMessage>> questionAnswerPairs = {};

    // 모든 질문을 먼저 처리
    for (var question in response.resMsg.questions) {
      final questionMessage = _ChatMessage(
        sender: 'user',
        content: '${question.subject}\n\n${question.content}',
        date: DateTime.parse(question.createdAt.replaceAll(' ', 'T')),
        questionId: question.id,
        status: question.status,
        subject: question.subject,
        originalContent: question.content,
      );

      // 질문 ID를 키로 맵에 추가
      questionAnswerPairs[question.id] = [questionMessage];

      // 답변이 있으면 질문 바로 다음에 추가
      if (question.answer != null) {
        final answerMessage = _ChatMessage(
          sender: 'cs',
          content: question.answer!.content,
          date: DateTime.parse(
            question.answer!.createdAt.replaceAll(' ', 'T'),
          ),
        );
        questionAnswerPairs[question.id]!.add(answerMessage);
      }
    }

    // 환영 메시지 추가
    messages.addAll([
      _ChatMessage(
        sender: 'cs',
        content: '안녕하세요. 버즈 고객센터 입니다.',
        date: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _ChatMessage(
        sender: 'cs',
        content: '궁금하신 점이나 문의 할 내역을 입력해 주시면 최대한 빠르게 답변 드리도록 하겠습니다! 감사합니다!',
        date: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ]);

    // 질문-답변 쌍을 날짜순으로 정렬
    final sortedQuestionIds = questionAnswerPairs.keys.toList()
      ..sort((a, b) {
        final dateA = questionAnswerPairs[a]![0].date;
        final dateB = questionAnswerPairs[b]![0].date;
        return dateA.compareTo(dateB);
      });

    // 정렬된 질문-답변 쌍을 메시지 목록에 추가
    for (var id in sortedQuestionIds) {
      messages.addAll(questionAnswerPairs[id]!);
    }

    setState(() {
      _messages = messages;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    setState(() {
      _messages.add(_ChatMessage(
        sender: 'user', 
        content: text, 
        date: now,
        subject: '문의',
        originalContent: text,
      ));
      _controller.clear();
    });

    final inquiryService = DioInquiryService();
    final success = await inquiryService.createInquiry('문의', text);

    if (!success && mounted) {
      Toast(context, '문의 전송에 실패했습니다.', icon: Icon(Icons.error, color: Colors.red));
    } else {
      // 문의 전송 성공 후 목록 새로고침
      _loadInquiries();
    }
  }

  // 문의 수정 함수
  void _editMessage(_ChatMessage message) async {
    if (message.questionId == null) {
      Toast(context, '아직 저장되지 않은 메시지는 수정할 수 없습니다.');
      return;
    }

    if (message.status == 'ANSWERED') {
      Toast(context, '답변이 완료된 문의는 수정할 수 없습니다.');
      return;
    }

    // 텍스트 컨트롤러에 기존 내용 설정
    final subjectController = TextEditingController(text: message.subject);
    final contentController = TextEditingController(text: message.originalContent);

    // 수정 다이얼로그 표시
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'subject': subjectController.text.trim(),
              'content': contentController.text.trim(),
            }),
            child: const Text('수정'),
          ),
        ],
      ),
    );

    if (result != null && result['subject'] != null && result['content'] != null) {
      final inquiryService = DioInquiryService();
      final success = await inquiryService.updateInquiry(
        message.questionId!,
        result['subject']!,
        result['content']!,
      );

      if (!success && mounted) {
        Toast(context, '문의 수정에 실패했습니다.', icon: const Icon(Icons.error, color: Colors.red));
      } else {
        // 성공 메시지 표시
        if (mounted) {
          Toast(context, '문의가 수정되었습니다.');
        }
        // 문의 목록 새로고침
        _loadInquiries();
      }
    }
  }

  // 문의 삭제 함수
  void _deleteMessage(_ChatMessage message) async {
    if (message.questionId == null) {
      Toast(context, '아직 저장되지 않은 메시지는 삭제할 수 없습니다.');
      return;
    }

    if (message.status == 'ANSWERED') {
      Toast(context, '답변이 완료된 문의는 삭제할 수 없습니다.');
      return;
    }

    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의 삭제'),
        content: const Text('이 문의를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final inquiryService = DioInquiryService();
      final success = await inquiryService.deleteInquiry(message.questionId!);

      if (!success && mounted) {
        Toast(context, '문의 삭제에 실패했습니다.', icon: Icon(Icons.error, color: Colors.red));
      } else {
        // 성공 메시지 표시
        if (mounted) {
          Toast(context, '문의가 삭제되었습니다.');
        }
        // 문의 목록 새로고침
        _loadInquiries();
      }
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
                      child: GestureDetector(
                        onLongPress: isUser && msg.questionId != null 
                            ? () => _showMessageOptions(msg) 
                            : null,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFFFFE0B2)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isUser && msg.subject != null && msg.subject != '문의')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    msg.subject!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                isUser ? (msg.originalContent ?? msg.content) : msg.content,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(msg.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  if (isUser && msg.status != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        ' • ${_getStatusText(msg.status!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(msg.status!),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
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

  // 롱 프레스 시 메시지 옵션 표시
  void _showMessageOptions(_ChatMessage message) {
    final canModify = message.status != 'ANSWERED';
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canModify) ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정하기'),
            onTap: () {
              Navigator.pop(context);
              _editMessage(message);
            },
          ),
          if (canModify) ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제하기'),
            onTap: () {
              Navigator.pop(context);
              _deleteMessage(message);
            },
          ),
          if (!canModify) const ListTile(
            title: Text('답변이 완료된 문의는 수정/삭제할 수 없습니다.'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 문의 상태 텍스트 반환
  String _getStatusText(String status) {
    switch (status) {
      case 'ANSWERED':
        return '답변 완료';
      case 'WAITING':
        return '답변 대기중';
      default:
        return status;
    }
  }

  // 문의 상태 색상 반환
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ANSWERED':
        return Colors.green;
      case 'WAITING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
  final int? questionId;
  final String? status;
  final String? subject;
  final String? originalContent;

  _ChatMessage({
    required this.sender,
    required this.content,
    required this.date,
    this.questionId,
    this.status,
    this.subject,
    this.originalContent,
  });
}
