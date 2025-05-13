// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_list_model.dart';
import 'package:buds/screens/letter/letter_anonymity_screen.dart';
import 'package:buds/screens/letter/letter_list_screen.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  int letterCnt = 0;

  @override
  void initState() {
    super.initState();
    fetchLetterCount();
  }

  Future<void> fetchLetterCount() async {
    try {
      final letterResponse = await LetterService().fetchLetters();
      if (letterResponse.letters.isNotEmpty) {
        setState(() {
          letterCnt = letterResponse.letterCnt;
        });
      } else {
        setState(() {
          letterCnt = 0;
        });
      }
    } catch (e) {
      print('편지 수 조회 에러: $e');
      setState(() {
        letterCnt = 0;
      });
    }
  }

  void updateLetterCount(int count) {
    setState(() {
      letterCnt = count;
    });
  }

  void navigateToWrite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LetterAnonymityScreen()),
    ).then((_) {
      fetchLetterCount(); // 돌아왔을 때 리스트 새로고침
      // letter list 조회 api로 초기화해야함
    });
  }

  @override
  Widget build(BuildContext context) {
    // 가로 모드 감지
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // 가로 모드 시 마진 조정
    final paddingValue = isLandscape ? 32.0 : 16.0;

    return Scaffold(
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // 퀘스트 배너
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.skyblue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '오늘의 퀘스트를 완료하고\n편지지를 모아봐요',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 16),
                  child: Image.asset(
                    'assets/images/marmet_cutting_head.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          ),

          // 탭 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  '편지 목록',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                const Spacer(),
                Text(
                  '나의 편지 $letterCnt', // LetterModel의 letterCnt 사용
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 편지 목록 컴포넌트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LetterList(
                onCountFetched: updateLetterCount,
                onWritePressed: navigateToWrite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
