// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/screens/letter/letter_answer_screen.dart';
import 'package:buds/screens/letter/widgets/letter_content_view.dart';
import 'package:buds/screens/letter/widgets/letter_detail_header.dart';
import 'package:buds/screens/letter/widgets/letter_page_dots.dart';
import 'package:buds/screens/letter/widgets/letter_pagination.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterDetailScreen extends StatefulWidget {
  final int opponentId;
  final String opponentName;

  const LetterDetailScreen({
    super.key,
    required this.opponentId,
    required this.opponentName,
  });

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Provider로 편지 상세 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LetterProvider>(
        context,
        listen: false,
      ).fetchLetterDetails(opponentId: widget.opponentId);
    });
  }

  // ⭐ 받침 여부에 따른 '에게' / '게' 처리 함수
  String getPostpositionTo(String name) {
    if (name.isEmpty) return "에게";
    final lastChar = name.characters.last;
    final hasFinalConsonant = (lastChar.codeUnitAt(0) - 0xAC00) % 28 != 0;
    return hasFinalConsonant ? "게" : "에게";
  }

  // ⭐ 받침 여부에 따른 '이' / '가' 처리 함수
  String getPostpositionFrom(String name) {
    if (name.isEmpty) return "가";
    final lastChar = name.characters.last;
    final hasFinalConsonant = (lastChar.codeUnitAt(0) - 0xAC00) % 28 != 0;
    return hasFinalConsonant ? "이" : "가";
  }

  /// 최신부터 몇 번째 편지인지 정확히 계산
  int calculateLetterNumber(LetterProvider provider) {
    if (provider.letterPage == null) return 0;

    // 총 편지 수 = (전체 페이지 수 - 현재 페이지) * 5 - (현재 페이지의 편지 인덱스)
    int totalLetters =
        (provider.letterPage!.totalPages - provider.currentPage - 1) * 5 +
        (5 - provider.currentLetterIndex);
    return totalLetters;
  }

  // 캐러셀에서 편지 변경 시 처리
  void _onLetterChanged(int index, LetterProvider provider) {
    if (provider.currentLetterIndex != index) {
      provider.setCurrentLetterIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loggedInUser = authProvider.userData?['name'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Consumer<LetterProvider>(
        builder: (context, letterProvider, _) {
          if (letterProvider.isLoadingPage || letterProvider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentLetter = letterProvider.currentLetter;
          if (currentLetter == null || letterProvider.letterPage == null) {
            return const Center(child: Text('편지를 불러올 수 없습니다.'));
          }

          final isReceived = currentLetter.receiverName == loggedInUser;

          // 최신 페이지(0)의 첫 번째 편지(0)이고 받은 편지일 경우에만 답장 버튼 표시
          final isLatestPage = letterProvider.currentPage == 0;
          final isLatestLetter = letterProvider.currentLetterIndex == 0;
          final isLatestReceivedLetter =
              isLatestPage && isLatestLetter && isReceived;

          return Column(
            children: [
              // 상단 탭
              LetterDetailHeader(
                isReceived: isReceived,
                letterId: currentLetter.letterId,
                letterNumber: calculateLetterNumber(letterProvider),
              ),

              const SizedBox(height: 5),

              // 편지 내용
              Expanded(
                child: LetterContentView(
                  letter: currentLetter,
                  recipientName: loggedInUser,
                  recipientPostPosition: getPostpositionTo(
                    isReceived ? loggedInUser : widget.opponentName,
                  ),
                  senderPostPosition: getPostpositionFrom(
                    currentLetter.senderName,
                  ),
                ),
              ),

              // 최신 편지이고 상대방이 보낸 편지인 경우에만 답장 버튼 표시
              if (isLatestReceivedLetter)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      // 답장하기 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LetterAnswerScreen(
                                letterId: currentLetter.letterId,
                                senderName: widget.opponentName,
                                redirectRoute: '/letter',
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '답장하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // 페이지네이션 UI
              LetterPagination(
                provider: letterProvider,
                opponentId: widget.opponentId,
                buildPageDots: buildLetterPageDots,
              ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
