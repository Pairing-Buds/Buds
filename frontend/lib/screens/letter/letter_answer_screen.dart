import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/config/theme.dart';

class LetterAnswerScreen extends StatefulWidget {
  final int? letterId; // 편지 세부내역 : 답장할 편지 ID (optional)
  final int? userId; // 추천 친구 : 새로 보낼 사용자 ID (optional)
  final String? senderName; // 받는 사람 닉네임
  final String? receiverName; // 사용자 닉네임

  const LetterAnswerScreen({
    Key? key,
    this.letterId,
    this.userId,
    this.senderName,
    this.receiverName,
  }) : super(key: key);

  @override
  State<LetterAnswerScreen> createState() => _LetterAnswerScreenState();
}

class _LetterAnswerScreenState extends State<LetterAnswerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 수신자 표시
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Text(
                              widget.letterId != null
                                  ? 'To: ${widget.senderName ?? "익명"}'
                                  : 'To: ${widget.receiverName ?? "익명"}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        today,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 편지 입력 필드
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _controller,
                          expands: true,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: '클릭하고 편지를 입력해보세요',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 수신자 (현재 사용자) 표시
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'From: ${widget.receiverName}', // 사용자 이름 (수신자)
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 답장 보내기 버튼
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _sendLetter,

                        child: Container(
                          width: 140,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isLoading ? Colors.grey : AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      '편지보내기',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 편지 또는 답장 전송 함수
  Future<void> _sendLetter() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('편지 내용을 입력해주세요')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (widget.letterId != null) {
        // 답장 전송 (Letter ID 사용)
        success = await LetterService().sendletterAnswer(
          widget.letterId!,
          content,
        );
      } else if (widget.userId != null) {
        // 새 편지 전송 (User ID 사용)
        success = await ActivityService().sendUserLetter(
          widget.userId!,
          content,
        );
      } else {
        throw Exception('잘못된 요청: letterId나 userId 중 하나가 필요합니다.');
      }

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('편지를 성공적으로 보냈습니다')));
        _controller.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('편지 전송에 실패했습니다.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('편지 전송 오류: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
