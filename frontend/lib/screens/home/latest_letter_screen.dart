// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:async'; // Timer 사용
// Package imports:
import 'package:provider/provider.dart';
import 'dart:async'; // Timer 사용

// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/models/letter_latest_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/screens/letter/letter_answer_screen.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'package:rive/rive.dart' as riv;

class LastLetterScreen extends StatefulWidget {
  const LastLetterScreen({Key? key}) : super(key: key);

  @override
  State<LastLetterScreen> createState() => _LastLetterScreenState();
}

class _LastLetterScreenState extends State<LastLetterScreen> {
  LatestLetterModel? latestLetter;
  bool isLoading = true;
  Timer? redirectTimer; // 자동 리다이렉트 타이머

  @override
  void initState() {
    super.initState();
    loadLatestLetter();
  }

  // 최신 편지 로드 함수
  Future<void> loadLatestLetter() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedLetter = await LetterService().fetchLetterLatest();
      setState(() {
        latestLetter = fetchedLetter;
      });

      // 편지가 없을 때만 타이머로 자동 리다이렉트 설정
      if (fetchedLetter == null) {
        _startRedirectTimer();
      }
    } catch (e) {
      if (e.toString().contains("404")) {
        // 편지가 없을 경우 5초 뒤 자동 리다이렉트
        _startRedirectTimer();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("오류 발생: ${e.toString()}")));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 5초 뒤 /main으로 자동 리다이렉트 함수
  void _startRedirectTimer() {
    // 기존 타이머가 있을 경우 취소
    redirectTimer?.cancel();
    redirectTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        Navigator.popAndPushNamed(context, '/main');
      }
    });
  }

  @override
  void dispose() {
    // 페이지 종료 시 타이머 해제
    redirectTimer?.cancel();
    super.dispose();
  }

  // 발신자 이름에서 받침 여부에 따른 "으로부터" 또는 "로부터" 설정
  String getSenderWithPostposition(String senderName) {
    if (senderName.isEmpty) return "익명의 누군가로부터";

    final lastChar = senderName.characters.last;
    final isConsonant =
        RegExp(r'[가-힣]').hasMatch(lastChar) &&
        (lastChar.codeUnitAt(0) - 0xAC00) % 28 == 0; // 받침이 없으면 true

    return isConsonant ? "$senderName로부터" : "$senderName으로부터";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final receiverName = authProvider.userData?['name'] ?? '나';

    return Scaffold(
      appBar: const CustomAppBar(
        title: '익명의 편지',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : latestLetter == null
              ? Stack(
                children: [
                  // Rive 애니메이션 배경
                  Positioned.fill(
                    child: Transform.translate(
                      offset: const Offset(0, 0),
                      child: riv.RiveAnimation.asset(
                        'assets/animations/sea.riv',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  // 안내 텍스트 (흰색 둥근 네모 박스, 갈색 텍스트)
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "편지가 오고 있어요.\n 기다려보세요",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A4E42), // 갈색 텍스트
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
              : Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/sea_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  // 편지 화면 중앙보다 위쪽으로 정렬
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 편지지 이미지
                        Image.asset(
                          'assets/images/vintage_l.png',
                          width: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.contain,
                        ),
                        // 발신자 이름
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.12,
                          child: Text(
                            getSenderWithPostposition(
                              latestLetter?.senderName ?? '익명의 누군가',
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 편지 내용
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.18,
                          left: MediaQuery.of(context).size.width * 0.12,
                          right: MediaQuery.of(context).size.width * 0.12,
                          bottom: MediaQuery.of(context).size.height * 0.05,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: SingleChildScrollView(
                              child: Text(
                                latestLetter?.content ??
                                    "아직 들어온 편지가 없네요\n 편지를 기다려보세요",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 답장하기 버튼
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (latestLetter == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('들어온 편지가 없어 답장을 할 수 없어요'),
                              ),
                            );
                            return;
                          }

                          // LetterAnswerScreen으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LetterAnswerScreen(
                                    letterId: latestLetter!.letterId,
                                    receiverName: receiverName,
                                    senderName: latestLetter!.senderName,
                                    redirectRoute: '/main',
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "답장하기",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
