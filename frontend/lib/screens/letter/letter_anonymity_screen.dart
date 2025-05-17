// Flutter imports:
import 'package:flutter/material.dart';
// import 'dart:math';
// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/api_service.dart';
import 'package:buds/screens/letter/letter_screen.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/widgets/toast_bar.dart';

class LetterAnonymityScreen extends StatefulWidget {
  const LetterAnonymityScreen({Key? key}) : super(key: key);

  @override
  State<LetterAnonymityScreen> createState() => _LetterAnonymityScreenState();
}

class _LetterAnonymityScreenState extends State<LetterAnonymityScreen> {
  bool isInterest = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 로그인한 사용자 닉네임 가져오기
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userData?['name'] ?? '익명 사용자';
    String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 오버플로우 방지
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '보낼 편지',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isInterest = !isInterest;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isInterest ? AppColors.blue : AppColors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isInterest ? '관심' : '랜덤',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isInterest ? Colors.black : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
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
                      const Text(
                        '익명의 누군가에게',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '작성일: $today',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'From: $userName',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _sendLetter,
                child: Container(
                  width: 140,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      '편지보내기',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 전송 함수 (유지)
  Future<void> _sendLetter() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('편지 내용을 입력해주세요')));
      return;
    }

    final requestBody = {'content': content, 'isTagBased': isInterest};

    try {
      final response = await DioApiService().post(
        ApiConstants.letterAnonymityUrl,
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Toast(
          context,
          '편지를 성공적으로 보냈습니다',
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
        _controller.clear();
        Navigator.pushReplacementNamed(context, '/letter');
      }
    } catch (e) {
      Toast(
        context,
        '편지 전송에 실패했습니다',
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}

// 전송 버튼
// Padding(
//   padding: const EdgeInsets.symmetric(vertical: 12),
//   child: ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: AppColors.primary,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//       minimumSize: const Size(140, 44),
//     ),
//     onPressed: _sendLetter,
//     child: const Text(
//       '편지보내기',
//       style: TextStyle(color: Colors.black, fontSize: 16),
//     ),
//   ),
// ),
