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
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/models/letter_content_model.dart';
import 'package:buds/models/letter_detail_model.dart';

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
  // 캐러셀용 컨트롤러 추가
  final PageController _pageController = PageController(
    viewportFraction: 0.9,
    initialPage: 0,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  @override
  void didUpdateWidget(LetterDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // opponentId가 변경되었을 때만 데이터 다시 로드
    if (oldWidget.opponentId != widget.opponentId) {
      Provider.of<LetterProvider>(
        context,
        listen: false,
      ).fetchLetterDetails(opponentId: widget.opponentId);
    }
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

  // 캐러셀에서 페이지 변경 시 처리
  void _onPageChanged(int index, LetterProvider provider) {
    provider.setCurrentLetterIndex(index);
  }

  // 부드러운 페이지 전환을 위한 메서드 추가
  void _animateToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 간단한 스와이프 감지 함수
  void _handleSwipe(double velocity, LetterProvider provider) {
    if (velocity < -800 &&
        provider.currentLetterIndex ==
            provider.letterPage!.letters.length - 1 &&
        provider.currentPage < provider.letterPage!.totalPages - 1) {
      // 왼쪽으로 스와이프하고 현재 페이지의 마지막 편지면 다음 페이지로
      provider.fetchLetterDetails(
        opponentId: widget.opponentId,
        page: provider.currentPage + 1,
      );
    } else if (velocity > 800 &&
        provider.currentLetterIndex == 0 &&
        provider.currentPage > 0) {
      // 오른쪽으로 스와이프하고 현재 페이지의 첫 편지면 이전 페이지로
      provider.fetchLetterDetails(
        opponentId: widget.opponentId,
        page: provider.currentPage - 1,
      );
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

          final letters = letterProvider.letterPage?.letters;
          if (letters == null || letters.isEmpty) {
            return const Center(child: Text('편지를 불러올 수 없습니다.'));
          }

          final currentLetter = letterProvider.currentLetter;
          if (currentLetter == null) {
            return const Center(child: Text('편지 내용을 불러올 수 없습니다.'));
          }

          final isReceived = currentLetter.receiverName == loggedInUser;

          // 최신 페이지(0)의 첫 번째 편지(0)이고 받은 편지일 경우에만 답장 버튼 표시
          final isLatestPage = letterProvider.currentPage == 0;
          final isLatestLetter = letterProvider.currentLetterIndex == 0;
          final isLatestReceivedLetter =
              isLatestPage && isLatestLetter && isReceived;

          // 페이지 컨트롤러 초기 페이지 설정 (현재 선택된 편지로)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              // 페이지가 완전히 로드된 후에 애니메이션 적용
              if (_pageController.page?.toInt() !=
                  letterProvider.currentLetterIndex) {
                _animateToPage(letterProvider.currentLetterIndex);
              }
            }
          });

          return Column(
            children: [
              // 상단 탭
              LetterDetailHeader(
                isReceived: isReceived,
                letterId: currentLetter.letterId,
                letterNumber: calculateLetterNumber(letterProvider),
              ),

              const SizedBox(height: 5),

              // 편지 내용 (PageView로 구현)
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // 스와이프 감지하여 페이지 전환
                    _handleSwipe(
                      details.velocity.pixelsPerSecond.dx,
                      letterProvider,
                    );
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: letters.length,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    onPageChanged:
                        (index) => _onPageChanged(index, letterProvider),
                    itemBuilder: (context, index) {
                      // 이미 캐싱 메커니즘이 있으므로 항상 provider에서 현재 선택된 편지를 요청
                      // index가 현재 선택된 인덱스와 다를 경우 자동으로 fetchSingleLetter가 호출됨
                      final isCurrentIndex =
                          index == letterProvider.currentLetterIndex;

                      return LetterContentView(
                        letter: currentLetter,
                        recipientName: loggedInUser,
                        recipientPostPosition: getPostpositionTo(
                          isReceived ? loggedInUser : widget.opponentName,
                        ),
                        senderPostPosition: getPostpositionFrom(
                          letters[index].senderName,
                        ),
                      );
                    },
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
                      ).then((result) {
                        // 편지 전송이 성공적으로 이루어진 경우에만 새로고침
                        if (result == true) {
                          // 편지함으로 돌아왔을 때 편지 목록 새로고침
                          letterProvider.fetchLetters();

                          // 현재 편지 대화 내용도 새로고침
                          letterProvider.fetchLetterDetails(
                            opponentId: widget.opponentId,
                            page: 0,
                          );
                        }
                      });
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

              // dots 인디케이터만 표시
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildLetterPageDots(letterProvider),
                ),
              ),

              // 현재 페이지 표시 (작게)
              if (letterProvider.letterPage != null &&
                  letterProvider.letterPage!.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '페이지 ${letterProvider.currentPage + 1} / ${letterProvider.letterPage!.totalPages}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              // 페이지 이동 버튼 (필요한 경우에만 표시)
              if (letterProvider.letterPage != null &&
                  letterProvider.letterPage!.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (letterProvider.currentPage > 0)
                        IconButton(
                          onPressed: () {
                            letterProvider.fetchLetterDetails(
                              opponentId: widget.opponentId,
                              page: letterProvider.currentPage - 1,
                            );
                          },
                          icon: const Icon(Icons.arrow_back, size: 20),
                          tooltip: '최신 편지로 이동',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 32),
                      if (letterProvider.currentPage <
                          letterProvider.letterPage!.totalPages - 1)
                        IconButton(
                          onPressed: () {
                            letterProvider.fetchLetterDetails(
                              opponentId: widget.opponentId,
                              page: letterProvider.currentPage + 1,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          tooltip: '과거 편지로 이동',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
