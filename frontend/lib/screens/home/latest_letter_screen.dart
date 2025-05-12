import 'package:flutter/material.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_content_model.dart';
import 'package:buds/screens/letter/letter_anonymity_screen.dart';

class LastLetterScreen extends StatefulWidget {
  const LastLetterScreen({Key? key}) : super(key: key);

  @override
  State<LastLetterScreen> createState() => _LastLetterScreenState();
}

class _LastLetterScreenState extends State<LastLetterScreen> {
  LetterContentModel? letterContent;
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
      // 최신 편지 ID 로드
      final latestLetter = await LetterService().fetchLetterLatest();
      final letterId = latestLetter.letterId;

      if (letterId == 0) {
        throw Exception('유효한 편지 ID를 찾을 수 없습니다.');
      }

      // 편지 상세 조회
      final fetchedLetter = await LetterService().fetchSingleLetter(letterId);
      setState(() {
        letterContent = fetchedLetter;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("편지 로드 실패: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Positioned.fill(
            child: Image.asset(
              'assets/images/sea_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // 편지 화면 중앙 정렬
          Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/vintage_l.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.contain,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      letterContent?.senderName ?? "발신자 없음",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      letterContent?.content ?? "편지 내용을 불러올 수 없습니다.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 답장하기 버튼 반응형 위치
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 답장하기 버튼 동작 추가
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // 버튼 색상
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
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
