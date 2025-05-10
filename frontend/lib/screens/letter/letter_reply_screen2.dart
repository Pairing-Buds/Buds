import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/screens/letter/letter_send_screen.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_detail_model.dart';

class LetterReplyScreen2 extends StatefulWidget {
  final LetterDetailModel letterDetail;

  const LetterReplyScreen2({
    Key? key,
    required this.letterDetail,
  }) : super(key: key);

  @override
  State<LetterReplyScreen2> createState() => _LetterReplyScreenState();
}

class _LetterReplyScreenState extends State<LetterReplyScreen2> {
  late bool _isScraped;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isScraped = false; // 초기값
  }

  Future<void> _toggleScrap() async {
    if (_isLoading) return;

    setState(() { _isLoading = true; });

    try {
      final success = await LetterService().toggleScrap(widget.letterDetail.letterId);

      if (success) {
        setState(() { _isScraped = !_isScraped; });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스크랩 상태 변경에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Text('받은 편지', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const Spacer(),
                Text('${widget.letterDetail.letterId}번째 편지', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),

          // 편지 카드
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${widget.letterDetail.senderName}에게', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(widget.letterDetail.createdAt, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(widget.letterDetail.content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 답장하기 버튼
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LetterSendScreen(),
                  ),
                );
              },
              child: const Text('답장하기'),
            ),
          ),
        ],
      ),
    );
  }
}
