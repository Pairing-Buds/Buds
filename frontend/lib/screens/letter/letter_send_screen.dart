// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/letter_content_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterSendScreen extends StatefulWidget {
  final int letterId;

  const LetterSendScreen({
    Key? key,
    required this.letterId,
  }) : super(key: key);

  @override
  _LetterSendScreenState createState() => _LetterSendScreenState();
}

class _LetterSendScreenState extends State<LetterSendScreen> {
  LetterContentModel? _letterDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLetterContent();
  }

  /// ✅ 편지 내용 조회
  Future<void> fetchLetterContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await LetterService().fetchSingleLetter(widget.letterId);
      setState(() {
        _letterDetail = detail;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('편지 내용을 불러올 수 없습니다: $e')),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _letterDetail == null
          ? const Center(child: Text('편지 내용을 불러올 수 없습니다.'))
          : Column(
        children: [
          // 상단 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: const [
                Text(
                  '보낼 편지',
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
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
                    // 1. 수신자 정보
                    Row(
                      children: [
                        const Expanded(child: SizedBox()), // 왼쪽 빈 공간
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Text(
                              'To: ${_letterDetail?.receiverName ?? '알 수 없음'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Image.asset(
                              'assets/icons/letter/send.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. 날짜
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '작성일: ${_letterDetail?.createdAt ?? '알 수 없음'}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. 편지 내용 : 스크롤 가능
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _letterDetail?.content ?? '내용이 없습니다.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // 4. 송신자 정보
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'From: ${_letterDetail?.senderName ?? '알 수 없음'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // 전송 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: const Size(140, 44),
              ),
              onPressed: _sendLetter,
              child: const Text(
                '편지보내기',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ 편지 전송 로직 (추가 가능)
  void _sendLetter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('편지를 성공적으로 보냈습니다.')),
    );
  }
}
