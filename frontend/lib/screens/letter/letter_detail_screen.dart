// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/models/letter_page_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
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
  LetterPageModel? letterPage; // ⭐ 페이지네이션 정보와 편지 리스트 관리
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLetters(); // ⭐ 초기 로드시 편지 목록 로드
  }

  /// ⭐ 페이지네이션 적용된 편지 목록 로드
  Future<void> loadLetters({int page = 0}) async {
    setState(() => isLoading = true);

    try {
      final response = await LetterService().fetchLetterDetails(
        opponentId: widget.opponentId,
        page: page,
        size: 5,
      );

      setState(() {
        letterPage = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('편지 로드 실패: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 다음 페이지로 이동
  void nextPage() {
    if (letterPage != null &&
        letterPage!.currentPage < letterPage!.totalPages - 1) {
      loadLetters(page: letterPage!.currentPage + 1);
    }
  }

  /// 이전 페이지로 이동
  void previousPage() {
    if (letterPage != null && letterPage!.currentPage > 0) {
      loadLetters(page: letterPage!.currentPage - 1);
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
        leftIconPath: 'assets/icons/bottle_icon.png',
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
                        letterPage != null && letterPage!.letters.isNotEmpty
                            ? buildLetterContent(
                              letterPage!.letters.first,
                              loggedInUser,
                            )
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
                        '${(letterPage?.currentPage ?? 0) + 1} / ${letterPage?.totalPages ?? 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: nextPage,
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
    );
  }

  /// 편지 내용 UI 빌드 (노란색 박스 + 분기 처리)
  Widget buildLetterContent(LetterDetailModel letter, String loggedInUser) {
    final isReceived = letter.received;

    return Stack(
      children: [
        // 노란색 박스 (높이: 전체 화면의 60%)
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
                        ? 'To: $loggedInUser'
                        : 'To: ${widget.opponentName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    isReceived
                        ? 'assets/icons/letter/reply.png'
                        : 'assets/icons/letter/send.png',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 날짜
              Text(
                'Date: ${letter.createdAt}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // 편지 내용 (스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    letter.status,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 하단 (From:)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  isReceived
                      ? 'From: ${letter.senderName}'
                      : 'From: $loggedInUser',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),

        //  스크랩 아이콘 (received: true 일때만)
        if (isReceived)
          Positioned(
            top: 0,
            left: 10,
            child: GestureDetector(
              onTap: () {
                print('스크랩 클릭');
              },
              child: Image.asset(
                'assets/icons/letter/scrap_inactive.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
      ],
    );
  }
}
