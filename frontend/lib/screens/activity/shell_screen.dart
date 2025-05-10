import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/models/activity_model.dart';
import 'package:buds/services/activity_service.dart';
import 'package:buds/widgets/custom_app_bar.dart';

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

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
    } else {
      _recognizedText = '';
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        localeId: 'ko_KR',
      );
    }

    setState(() => _isListening = !_isListening);
  }

  // STT 결과 전송하기
  void _sendReadText() async {
    final success = await ActivityService().submitSttResult(
      originalSentenceText: _quote?.sentence ?? "",
      userSentenceText: _recognizedText,
    );

    if (success) {
      print("STT 결과 전송 성공");
    } else {
      print("STT 결과 전송 실패");
    }
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
                          _quote?.sentence ?? '"명언을 불러오는 중..."',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _quote?.speaker ?? '알 수 없음',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                        Image.asset('assets/images/marmet_cutting_head.png', width: 80, height: 80),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _toggleListening,
                          child: Image.asset('assets/images/stand_mic.png', width: 40, height: 40),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _toggleListening,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_isListening ? '다시 읽기' : '따라 읽기'),
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

          if (_recognizedText.isNotEmpty)
            ElevatedButton(
              onPressed: _sendReadText,
              child: const Text('전송하기'),
            ),
        ],
      ),
    );
  }
}