// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:speech_to_text/speech_to_text.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/activity_quote_model.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:buds/widgets/common_dialog.dart';
import 'package:buds/widgets/toast_bar.dart';


class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _hasSpeech = false;
  String _recognizedText = '';
  double _similarity = 0.0;
  ActivityQuoteModel? _quote;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _fetchQuote();
  }

  Future<void> _initSpeech() async {
    _hasSpeech = await _speech.initialize(
      onError: (e) => print('STT 초기화 오류: $e'),
      onStatus: (status) => print('STT 상태: $status'),
    );
    setState(() {});
  }

  Future<void> _fetchQuote() async {
    try {
      final quote = await ActivityService().fetchDailyQuote();
      setState(() {
        _quote = quote;
      });
    } catch (e) {
      print('명언 불러오기 오류: $e');
    }
  }

  // 유사도 계산 (STT 결과 vs 원문)
  double _calcSimilarity() {
    if (_quote == null || _recognizedText.isEmpty) return 0;
    return similarity(_quote!.sentence, _recognizedText);
  }

  // STT 듣기 시작/정지
  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _similarity = _calcSimilarity();
      });
    } else {
      _recognizedText = '';
      _similarity = 0;
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) {
              _similarity = _calcSimilarity();
              if (_similarity < 0.7) {
                _showLowSimilarityWarning();
              }
            }
          });
        },
        localeId: 'ko_KR',
      );
    }
    setState(() => _isListening = !_isListening);
  }

  // STT 결과 전송하기
  void _sendReadText() async {
    try {
      final success = await ActivityService().submitSttResult(
        originalSentenceText: _quote?.sentence ?? "",
        userSentenceText: _recognizedText,
      );

      if (success) {
        print("STT 결과 전송 성공");
        _showSuccessModal();
      } else {
        print("STT 결과 전송 실패");
        _showErrorModal();
      }
    } catch (e) {
      print("STT 제출 에러: $e");
      _showErrorModal();
    }
  }

  // 유사도 낮음 알림
  void _showLowSimilarityWarning() {
    Toast(context, '유사도가 낮아요. 다시 읽어주세요.');
  }


  // 에러 모달 (이미 편지지 받은 경우)
  void _showErrorModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonDialog(
        title: "오늘의 편지지",
        description: "오늘은 이미 편지지를 받았어요.",
        cancelText: "확인",
        confirmText: "", // 버튼 하나만
        onCancel: _redirectToHome,
        onConfirm: () {}, // 사용되지 않음
      ),
    );
    Future.delayed(const Duration(seconds: 2), _redirectToHome);
  }

  // 인증 성공 모달 + 홈 화면 리다이렉트
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonDialog(
        title: "인증 성공",
        description: "선물로 편지지 5장을 드립니다.",
        cancelText: "확인",
        confirmText: "", // 버튼 하나
        onCancel: () {
          Navigator.of(context).pop(); // dialog 닫기
          _redirectToHome(); // 닫은 후 이동
        },
        onConfirm: () {},
      ),
    );
  }

  // 홈 화면으로 리다이렉트 함수
  void _redirectToHome() {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '행운의 조개',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Image.asset('assets/images/lucky_shell.png', width: 270, height: 270),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.27,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 10.4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 18),
                        const Text('오늘의 한마디', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text(
                          _quote?.sentence ?? '"명언 불러오는 중..."',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _quote?.speaker ?? '알 수 없음',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🎤 버튼 영역
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/marmet_cutting_head.png',
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _toggleListening,
                          child: Image.asset(
                            'assets/images/stand_mic.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _toggleListening,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isListening
                                    ? Colors.transparent
                                    : AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _isListening ? '다시 읽기' : '따라 읽기',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // STT 결과 텍스트
          Text(
            _recognizedText.isNotEmpty
                ? '🗣️ $_recognizedText'
                : '🎤 따라 읽은 문장이 여기에 표시됩니다',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          if (_recognizedText.isNotEmpty && _similarity >= 0.7)
            ElevatedButton(
              onPressed: _sendReadText,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '편지지 받기',
                style: TextStyle(color: Color(0xFF5D4037)),
              ),
            ),
        ],
      ),
    );
  }
}

// Levenshtein 거리 (한국어 비교)
double similarity(String s1, String s2) {
  final dist = jamoLevenshtein(s1, s2);
  final maxLen = max(s1.length, s2.length);
  if (maxLen == 0) return 1;
  return (maxLen - dist) / maxLen;
}

int jamoLevenshtein(String s1, String s2) {
  if (s1.length < s2.length) return jamoLevenshtein(s2, s1);
  if (s2.isEmpty) return s1.length;

  List<double> prev = List.generate(s2.length + 1, (i) => i.toDouble());
  for (var i = 0; i < s1.length; i++) {
    List<double> curr = [i + 1];
    for (var j = 0; j < s2.length; j++) {
      final cost = (s1[i] == s2[j]) ? 0 : 1;
      final insert = prev[j + 1] + 1;
      final delete = curr[j] + 1;
      final replace = prev[j] + cost;
      curr.add([insert, delete, replace].reduce(min));
    }
    prev = curr;
  }
  return prev.last.toInt();
}
