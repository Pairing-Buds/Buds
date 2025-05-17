// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_content_model.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/models/letter_page_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'package:buds/providers/auth_provider.dart';

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
  LetterPageModel? letterPage; //  페이지네이션 정보와 편지 리스트 관리
  LetterContentModel? currentLetter; // 현재 선택된 편지 내용
  bool isLoading = false;
  int currentPage = 0; // 현재 페이지 (0부터 시작)
  int currentLetterIndex = 0; // 현재 페이지 내에서 편지 인덱스

  @override
  void initState() {
    super.initState();
    loadLetters(); // 초기 로드시 편지 목록 로드
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

  /// 페이지네이션 적용된 편지 목록 로드
  Future<void> loadLetters({int page = 0}) async {
    setState(() {
      isLoading = true;
      currentLetter = null;
    });

    try {
      final response = await LetterService().fetchLetterDetails(
        opponentId: widget.opponentId,
        page: page,
        size: 5,
      );

      setState(() {
        letterPage = response;
        currentPage = page;
        currentLetterIndex = letterPage!.letters.length - 1; // 최신 편지부터

        if (letterPage!.letters.isNotEmpty) {
          loadLetterContent(letterPage!.letters[0].letterId); // 첫 편지 내용 로드
        }
      });
    } catch (e) {
      Toast(context, '편지가 오고 있어요: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 개별 편지 내용 로드 (letterId 기준)
  Future<void> loadLetterContent(int letterId) async {
    setState(() => isLoading = true);
    try {
      final letterContent = await LetterService().fetchSingleLetter(letterId);
      setState(() {
        currentLetter = letterContent;
      });
    } catch (e) {
      Toast(context, '오류가 발생했습니다: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 페이지네이션 화살표로 전체 페이지 이동 왼)과거,  오)미래
  void nextPage() {
    if (letterPage != null && currentPage > 0) {
      loadLetters(page: currentPage - 1); // 미래 → 과거
    }
  }

  void previousPage() {
    if (letterPage != null && currentPage < letterPage!.totalPages - 1) {
      loadLetters(page: currentPage + 1); // 과거 → 미래
    }
  }

  List<Widget> buildPageDots() {
    if (letterPage == null) return [];

    return List.generate(letterPage!.letters.length, (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            currentLetterIndex = letterPage!.letters.length - 1 - index;
          });
          loadLetterContent(
            letterPage!
                .letters[letterPage!.letters.length - 1 - index]
                .letterId,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentLetterIndex == letterPage!.letters.length - 1 - index
                    ? AppColors.primary
                    : Colors.grey,
          ),
        ),
      );
    }).reversed.toList();
  }

  /// 최신부터 몇 번째 편지인지 정확히 계산
  int calculateLetterNumber() {
    if (letterPage == null) return 0;

    // 총 편지 수 = (전체 페이지 수 - 현재 페이지) * 5 - (현재 페이지의 편지 인덱스)
    int totalLetters =
        (letterPage!.totalPages - currentPage - 1) * 5 +
        (5 - currentLetterIndex);
    return totalLetters;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loggedInUser = authProvider.userData?['name'] ?? 'Unknown';
    final totalLetters = letterPage?.letters.length ?? 0;
    final isReceived = currentLetter?.receiverName == loggedInUser;
    final letterNumber = totalLetters - currentLetterIndex; // 최신이 1, 과거로 증가

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_letter.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // 상단 탭
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                    child: Row(
                      children: [
                        Text(
                          (isReceived ? '보낸 편지' : '받은 편지'),
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Spacer(),
                        // ⭐편지 ID, 편지 번호는 테스트 용으로 넣었습니다
                        // ⭐ 이 유저와 주고받은 편지가 표시되며 좋겠습니다 5번째 편지
                        Text(
                          currentLetter != null
                              ? '편지 ID: ${currentLetter!.letterId}'
                              : '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currentLetter != null
                              ? '편지 번호: ${calculateLetterNumber()}'
                              : '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child:
                        currentLetter != null
                            ? buildLetterContent(currentLetter!, loggedInUser)
                            : const Center(child: Text('편지를 불러올 수 없습니다.')),
                  ),

                  // ⭐ 페이지네이션 UI (노란 박스 바로 아래로 위치)
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ), // ⭐ 하단 여백 조정 (20)
                    margin: const EdgeInsets.only(
                      bottom: 20,
                    ), // ⭐ 추가 여백으로 네브바와 간격 확보
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: previousPage,
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                            Text(
                              '페이지: ${currentPage + 1} / ${letterPage?.totalPages ?? 1}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              onPressed: nextPage,
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buildPageDots(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
    );
  }

  /// 편지 내용 UI 빌드 (노란색 박스 + 분기 처리)
  Widget buildLetterContent(LetterContentModel letter, String loggedInUser) {
    final isReceived = letter.receiverName == loggedInUser;

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              // 상단 (To: / 아이콘)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isReceived
                        ? '${loggedInUser}${getPostpositionTo(loggedInUser)}'
                        : '${widget.opponentName}${getPostpositionTo(widget.opponentName)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    isReceived
                        ? 'assets/icons/letter/receive_letter_icon.png'
                        : 'assets/icons/letter/send_letter_icon.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '작성일: ${letter.createdAt}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    letter.content,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${letter.senderName}${getPostpositionFrom(letter.senderName)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        // 전송하기 버튼(박스외부)
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primary,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(24),
        //       ),
        //       minimumSize: const Size(double.infinity, 44), // 전체 너비 적용
        //     ),
        //     onPressed: _sendLetter,
        //     child: const Text(
        //       '편지보내기',
        //       style: TextStyle(color: Colors.black, fontSize: 16),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
