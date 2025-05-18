// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterSendScreen extends StatefulWidget {
  final int letterId;

  const LetterSendScreen({Key? key, required this.letterId}) : super(key: key);

  @override
  _LetterSendScreenState createState() => _LetterSendScreenState();
}

class _LetterSendScreenState extends State<LetterSendScreen> {
  @override
  void initState() {
    super.initState();
    // Provider를 사용하여 편지 내용 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LetterProvider>(
        context,
        listen: false,
      ).fetchSingleLetter(widget.letterId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          if (letterProvider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final letterDetail = letterProvider.currentLetter;
          if (letterDetail == null) {
            return const Center(child: Text('편지 내용을 불러올 수 없습니다.'));
          }

          return Column(
            children: [
              // 상단 탭
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: const [
                    Text(
                      '보낸 편지',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Spacer(),
                    Text(
                      '편지 내용',
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
                        // 수신자 정보
                        Row(
                          children: [
                            const Expanded(child: SizedBox()), // 왼쪽 빈 공간
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Text(
                                  'To: ${letterDetail.receiverName}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Image.asset(
                                  'assets/icons/letter/send_letter_icon.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 날짜
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '작성일: ${letterDetail.createdAt}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 편지 내용 : 스크롤 가능
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              letterDetail.content,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        // 송신자 정보
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'From: ${letterDetail.senderName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
