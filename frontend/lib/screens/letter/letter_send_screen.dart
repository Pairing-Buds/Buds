import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_content_model.dart';

class LetterSendScreen extends StatefulWidget {
  final int letterId; // letterId만 전달

  const LetterSendScreen({
    Key? key,
    required this.letterId,
  }) : super(key: key);

  @override
  State<LetterSendScreen> createState() => _LetterSendScreenState();
}

class _LetterSendScreenState extends State<LetterSendScreen> {
  LetterContentModel? _letterDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLetterDetail();
  }

  /// ✅ 편지 내용 조회 API (나중에 API 연결)
  Future<void> _fetchLetterDetail() async {
    setState(() {
      _isLoading = true;
    });

    // ✅ 더미 데이터 (나중에 API 연결 시 변경)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _letterDetail = LetterContentModel(
        letterId: widget.letterId,
        senderName: "당신", // 보내는 사람 (내가 보낸 편지)
        receiverName: "익명의 사용자", // 받는 사람
        content: "안녕하세요 카피바라입니다. 반가워요.",
        status: "SENT",
        createdAt: "2025-04-21", // yyyy.MM.dd 형식
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '보낸 편지',
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
              children: [
                Text(
                  '보낸 편지',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '편지 ID: ${_letterDetail!.letterId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
                    // 발신자와 수신자 정보
                    Text(
                      'From: ${_letterDetail!.senderName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To: ${_letterDetail!.receiverName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Date: ${_letterDetail!.createdAt}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // 편지 내용
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _letterDetail!.content,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 페이지네이션 (비활성)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_left, size: 32, color: Colors.grey),
                SizedBox(width: 8),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.arrow_right, size: 32, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
