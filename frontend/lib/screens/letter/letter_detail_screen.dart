// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_detail_model.dart';
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
  List<LetterDetailModel> letters = [];
  bool isLoading = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadLetters();
  }

  Future<void> loadLetters() async {
    setState(() => isLoading = true);

    try {
      final response = await LetterService().fetchLetterDetails(
        opponentId: widget.opponentId,
        page: 0,
        size: 5,
      );

      setState(() => letters = response);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('편지 로드 실패: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void nextPage() {
    if (currentPage < letters.length - 1) {
      setState(() => currentPage++);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
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
                        letters.isNotEmpty
                            ? buildLetterContent(
                              letters[currentPage],
                              loggedInUser,
                            )
                            : const Center(child: Text('편지를 불러올 수 없습니다.')),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: previousPage,
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Text(
                        '${currentPage + 1} / ${letters.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: nextPage,
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget buildLetterContent(LetterDetailModel letter, String loggedInUser) {
    final isReceived = letter.received;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Stack(
        children: [
          Container(
            // ⭐ 노란색 박스의 높이를 전체 화면의 60%로 설정
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          isReceived
                              ? 'To: $loggedInUser'
                              : 'To: ${widget.opponentName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
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
                Text(
                  'Date: ${letter.createdAt}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
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
          // ⭐ 스크랩 아이콘 (받은 편지일 때만 표시)
          if (isReceived)
            Positioned(
              top: 0,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  print('스크랩 클릭');
                },
                child: Image.asset(
                  'assets/icons/letter/scrap_skyblue.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
