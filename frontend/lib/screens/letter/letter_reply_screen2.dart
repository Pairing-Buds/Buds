import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/models/letter_content_model.dart';

class LetterReplyScreen2 extends StatefulWidget {
  final int letterId; // letterId만 전달

  const LetterReplyScreen2({
    Key? key,
    required this.letterId,
  }) : super(key: key);

  @override
  State<LetterReplyScreen2> createState() => _LetterReplyScreen2State();
}

class _LetterReplyScreen2State extends State<LetterReplyScreen2> {
  LetterContentModel? _letterDetail;
  bool _isLoading = true;
  bool _isScraped = false; // 스크랩 상태

  @override
  void initState() {
    super.initState();
    fetchLetterContent();
  }

  /// ✅ LetterContentModel (편지 내용) 조회
  Future<void> fetchLetterContent() async {
    print("⭐ Fetching letter content for letterId: ${widget.letterId}"); // ⭐ 디버깅 추가
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await LetterService().fetchSingleLetter(widget.letterId);
      setState(() {
        _letterDetail = detail;
      });
      print("⭐ Letter Content Loaded: ${_letterDetail?.content}"); // ⭐ 디버깅 추가
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

  /// ✅ 스크랩 토글
  Future<void> _toggleScrap() async {
    if (_isLoading || _letterDetail == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await LetterService().toggleScrap(widget.letterId);
      if (success) {
        setState(() {
          _isScraped = !_isScraped;
        });
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
        title: '받은 편지',
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
          // 상단 스크랩 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Text('받은 편지', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isScraped ? Icons.bookmark : Icons.bookmark_border,
                    color: _isScraped ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleScrap,
                ),
              ],
            ),
          ),

          // 편지 내용
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${_letterDetail!.senderName}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('To: ${_letterDetail!.receiverName}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Date: ${_letterDetail!.createdAt}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
