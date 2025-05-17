// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/screens/letter/letter_anonymity_screen.dart';
import 'package:buds/screens/letter/letter_list_screen.dart';
import 'package:buds/screens/letter/widgets/letter_header.dart';
import 'package:buds/screens/letter/widgets/letter_quest_banner.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  @override
  void initState() {
    super.initState();
    // Provider를 통해 편지 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LetterProvider>(context, listen: false).fetchLetters();
    });
  }

  void navigateToWrite() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LetterAnonymityScreen()),
    ).then((_) {
      // 화면으로 돌아왔을 때 편지 목록 새로고침
      Provider.of<LetterProvider>(context, listen: false).fetchLetters();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 가로 모드 감지
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // 가로 모드 시 마진 조정
    final paddingValue = isLandscape ? 50.0 : 16.0;

    return Scaffold(
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingValue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 퀘스트 배너
                  LetterQuestBanner(isLandscape: isLandscape),

                  // 탭 제목
                  const LetterHeader(),

                  const SizedBox(height: 8),

                  // 편지 목록 컴포넌트
                  SizedBox(
                    height:
                        isLandscape
                            ? constraints.maxHeight * 0.8
                            : constraints.maxHeight * 0.76,
                    child: LetterList(onWritePressed: navigateToWrite),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
