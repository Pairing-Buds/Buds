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
        currentLetterIndex = 0;

        if (letterPage!.letters.isNotEmpty) {
          loadLetterContent(letterPage!.letters[0].letterId); // 첫 편지 내용 로드
        }
      });
    } catch (e) {
      Toast(context, '편지 로드 실패: $e');
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
      Toast(context, '내용 로드 실패: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 페이지네이션 화살표로 전체 페이지 이동
  void nextPage() {
    if (letterPage != null && currentPage < letterPage!.totalPages - 1) {
      loadLetters(page: currentPage + 1);
    }
  }

  void previousPage() {
    if (letterPage != null && currentPage > 0) {
      loadLetters(page: currentPage - 1);
    }
  }

  /// 편지 점으로 세부 편지 선택
  List<Widget> buildPageDots() {
    if (letterPage == null) return [];

    return List.generate(letterPage!.letters.length, (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            currentLetterIndex = index;
          });
          loadLetterContent(letterPage!.letters[index].letterId);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentLetterIndex == index ? AppColors.primary : Colors.grey,
          ),
        ),
      );
    });
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        currentLetter != null
                            ? buildLetterContent(currentLetter!, loggedInUser)
                            : const Center(child: Text('편지를 불러올 수 없습니다.')),
                  ),
                  const SizedBox(height: 16),
                  // 페이지네이션 UI
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildPageDots(), //  편지 점 표시
                  ),
                  const SizedBox(height: 16),
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
            color: AppColors.cardBackground,
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
                        ? 'To. $loggedInUser'
                        : 'To. ${widget.opponentName}',
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
                  'From. ${letter.senderName}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
