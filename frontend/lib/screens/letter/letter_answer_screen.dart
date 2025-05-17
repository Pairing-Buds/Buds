import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'package:buds/screens/letter/widgets/letter_answer_header.dart';
import 'package:buds/screens/letter/widgets/letter_content_input.dart';
import 'package:buds/screens/letter/widgets/letter_sender_footer.dart';
import 'package:buds/screens/letter/widgets/letter_send_button.dart';

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
    final letterProvider = Provider.of<LetterProvider>(context);

    // 수신자와 발신자 이름 및 조사 설정
    final String recipientName =
        widget.letterId != null
            ? widget.senderName ?? "익명"
            : widget.receiverName ?? "나";
    final String recipientPostposition = getPostpositionTo(recipientName);

    final String senderName =
        widget.letterId != null
            ? widget.receiverName ?? "익명"
            : widget.senderName ?? "나";
    final String senderPostposition = getPostpositionFrom(senderName);

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
                // 수신자 헤더
                LetterAnswerHeader(
                  recipientName: recipientName,
                  postPosition: recipientPostposition,
                  date: today,
                ),
                const SizedBox(height: 20),

                // 편지 입력 필드
                LetterContentInput(controller: _controller),
                const SizedBox(height: 12),

                // 발신자 푸터
                LetterSenderFooter(
                  senderName: senderName,
                  postPosition: senderPostposition,
                ),
                const SizedBox(height: 12),

                // 답장 보내기 버튼
                LetterSendButton(
                  isLoading: letterProvider.isSending,
                  onTap: () => _sendLetter(letterProvider),
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
  Future<void> _sendLetter(LetterProvider provider) async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      Toast(
        context,
        '편지 내용을 입력해주세요.',
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    try {
      bool success;
      if (widget.letterId != null) {
        success = await provider.sendLetterAnswer(widget.letterId!, content);
      } else if (widget.userId != null) {
        success = await provider.sendUserLetter(widget.userId!, content);
      } else {
        throw Exception('잘못된 요청: letterId나 userId 중 하나가 필요합니다.');
      }

      if (success) {
        Toast(context, '편지가 전송되었습니다');
        Navigator.pop(context);
      } else {
        Toast(
          context,
          '편지 전송에 실패했습니다. 다시 시도해주세요.',
          icon: const Icon(Icons.error, color: Colors.red),
        );
        Navigator.pop(context);
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
    }
  }
}
