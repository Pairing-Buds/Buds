import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/screens/letter/letter_send_screen.dart';
import 'package:buds/services/letter_service.dart';

class LetterReplyScreen extends StatefulWidget {
  final int letterId;
  final bool isScraped;

  const LetterReplyScreen({
    Key? key,
    required this.letterId,
    this.isScraped = false,
  }) : super(key: key);

  @override
  State<LetterReplyScreen> createState() => _LetterReplyScreenState();
}

class _LetterReplyScreenState extends State<LetterReplyScreen> {
  late bool _isScraped;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isScraped = widget.isScraped;
  }

  Future<void> _toggleScrap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to toggle scrap status
      final success = await LetterService().toggleScrap(widget.letterId);

      if (success) {
        setState(() {
          _isScraped = !_isScraped;
        });
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스크랩 상태 변경에 실패했습니다.')),
        );
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 상단 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: const [
                Text(
                  '받은 편지',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Spacer(),
                Text(
                  'n번째 편지',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // 편지 카드
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Stack(
                children: [
                  Container(
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
                        const SizedBox(height: 34), // 스크랩 아이콘 높이 + 간격
                        // 1. 유저명, 하늘색 발신 아이콘
                        Row(
                          children: [
                            const Expanded(child: SizedBox()), // 왼쪽 빈 공간
                            const Expanded(
                              flex: 5,
                              child: Center(
                                child: Text(
                                  '사랑스러운 카피바라에게',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Image.asset(
                                  'assets/icons/letter/reply.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 2. 날짜
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '2025.04.21', //yyyy.mm.dd 형식
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. 편지 내용 : 스크롤 기능 존재
                        Center(
                          child: SizedBox(
                            height: 120, // 텍스트 영역의 최대 높이
                            child: SingleChildScrollView(
                              child: const Text(
                                '안녕하세요 너구리입니다.\n벌써 여름이 다가오고 있어요\n카피바라님의 하루는\n시원하길 바라요',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),

                        // 4. 수신자 정보
                        const Spacer(),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text('용감한 너구리가', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 12),

                        // 5. 답장 버튼
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LetterSendScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Text(
                                  '답장하기',
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  // 스크랩 아이콘 (상단에 포지션) - 클릭 가능하도록 수정
                  Positioned(
                    top: 0,
                    left: 20,
                    child: GestureDetector(
                      onTap: _toggleScrap,
                      child: _isLoading
                          ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                          : Image.asset(
                        _isScraped
                            ? 'assets/icons/letter/scrap_active.png'
                            : 'assets/icons/letter/scrap_inactive.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 페이지네이션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_left, size: 32),
                SizedBox(width: 8),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.brown),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.arrow_right, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}