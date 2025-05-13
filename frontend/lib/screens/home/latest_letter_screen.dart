// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:provider/provider.dart';
// Project imports:
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/models/letter_latest_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/screens/letter/letter_answer_screen.dart';

class LastLetterScreen extends StatefulWidget {
  const LastLetterScreen({Key? key}) : super(key: key);

  @override
  State<LastLetterScreen> createState() => _LastLetterScreenState();
}

class _LastLetterScreenState extends State<LastLetterScreen> {
  LatestLetterModel? latestLetter;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLatestLetter();
  }

  Future<void> loadLatestLetter() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 최신 편지 로드
      final fetchedLetter = await LetterService().fetchLetterLatest();
      setState(() {
        latestLetter = fetchedLetter;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("편지 로드 실패: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final receiverName = authProvider.userData?['name'] ?? '나';
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Positioned.fill(
            child: Image.asset('assets/images/sea_bg.png', fit: BoxFit.cover),
          ),
          // 편지 화면 중앙보다 위쪽으로 정렬 (0.3 위치)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset(
                  'assets/images/vintage_l.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  child: Text(
                    latestLetter?.senderName ?? "미상,로부터",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.18,
                  left: MediaQuery.of(context).size.width * 0.12,
                  right: MediaQuery.of(context).size.width * 0.12,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: SingleChildScrollView(
                      child: Text(
                        latestLetter?.content ?? "편지 내용을 불러올 수 없습니다.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 답장하기 버튼 반응형 위치
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (latestLetter == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('편지 정보를 불러올 수 없습니다.')),
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
