import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'package:buds/config/theme.dart';

class LetterAnswerScreen extends StatefulWidget {
  final int? letterId;
  final int? userId;
  final String? senderName;
  final String? receiverName;
  final String redirectRoute; // 리다이렉트할 페이지 지정

  const LetterAnswerScreen({
    Key? key,
    this.letterId,
    this.userId,
    this.senderName,
    this.receiverName,
    required this.redirectRoute, // 필수
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

  // 받침 여부에 따른 '에게' / '게' 처리 함수
  String getPostpositionTo(String name) {
    if (name.isEmpty) return "에게";
    final lastChar = name.characters.last;
    final hasFinalConsonant = (lastChar.codeUnitAt(0) - 0xAC00) % 28 != 0;
    return hasFinalConsonant ? "게" : "에게";
  }

  // 받침 여부에 따른 '이' / '가' 처리 함수
  String getPostpositionFrom(String name) {
    if (name.isEmpty) return "가";
    final lastChar = name.characters.last;
    final hasFinalConsonant = (lastChar.codeUnitAt(0) - 0xAC00) % 28 != 0;
    return hasFinalConsonant ? "이" : "가";
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 키보드로 인한 오버플로우 방지
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이 반영
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.letterBackground,
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
                              ? '${widget.senderName ?? "익명"}${getPostpositionTo(widget.senderName ?? "익명")}'
                              : '${widget.receiverName ?? "나"}${getPostpositionTo(widget.receiverName ?? "나")}',
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
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // 편지 입력 필드
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: MediaQuery.of(context).size.height * 0.4, //  최대 높이 제한
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: '클릭하고 편지를 입력해보세요',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 12),

                // 수신자 (현재 사용자) 표시
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    widget.letterId != null
                        ? '${widget.receiverName ?? "익명"}${getPostpositionFrom(widget.receiverName ?? "익명")}'
                        : '${widget.senderName ?? "나"}${getPostpositionFrom(widget.senderName ?? "나")}',
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
    );
  }

  /// 편지 또는 답장 전송 함수
  Future<void> _sendLetter() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      Toast(
        context,
        '편지 내용을 입력해주세요.',
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (widget.letterId != null) {
        success = await LetterService().sendletterAnswer(
          widget.letterId!,
          content,
        );
      } else if (widget.userId != null) {
        success = await ActivityService().sendUserLetter(
          widget.userId!,
          content,
        );
      } else {
        throw Exception('잘못된 요청: letterId나 userId 중 하나가 필요합니다.');
      }

      if (success) {
        Toast(context, '편지가 전송되었습니다');
        Navigator.pushReplacementNamed(context, widget.redirectRoute);
      } else {
        Toast(
          context,
          '편지 전송에 실패했습니다. 다시 시도해주세요.',
          icon: const Icon(Icons.error, color: Colors.red),
        );
        Navigator.pushReplacementNamed(context, widget.redirectRoute);
      }
    } catch (e) {
      if (e.toString().contains('409')) {
        Toast(
          context,
          '이미 보낸 편지입니다.',
          icon: const Icon(Icons.info, color: Colors.orange),
        );
      } else {
        Toast(
          context,
          '편지 전송 오류',
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
