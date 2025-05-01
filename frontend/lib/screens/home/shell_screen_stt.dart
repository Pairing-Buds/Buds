import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class ShellScreenSTT extends StatefulWidget {
  const ShellScreenSTT({super.key});

  @override
  State<ShellScreenSTT> createState() => _ShellScreenSTTState();
}

class _ShellScreenSTTState extends State<ShellScreenSTT> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _hasSpeech = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _hasSpeech = await _speech.initialize(
      onError: (e) => print('STT 초기화 오류: $e'),
      onStatus: (status) => print('STT 상태: $status'),
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_hasSpeech) {
      print('⚠️ STT 초기화 안됨');
      return;
    }

    setState(() {
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      localeId: 'ko_KR',
    );

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });

    print('🗣️ 인식된 텍스트: $_recognizedText');
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
          Container(height: 1, color: const Color(0xFFD7D7D7)),
          const SizedBox(height: 5),
          Image.asset('assets/images/lucky_shell.png', width: 310, height: 310),
          const SizedBox(height: 20),

          // 📦 흰 박스
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('오늘의 한마디', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              '"운과 유머가 세상을 지배하다."',
                              style: TextStyle(fontSize: 18, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '하비 콕스',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/marmet_cutting_head.png', width: 80, height: 80),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _isListening ? _stopListening : _startListening,
                          child: Image.asset(
                            'assets/images/stand_mic.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _isListening ? _stopListening : _startListening,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            '따라 읽기',
                            style: TextStyle(color: Colors.black, fontSize: 16),
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

          // 🗣️ STT 결과 텍스트 (흰 박스 아래에 표시)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _recognizedText.isNotEmpty
                  ? '🗣️ $_recognizedText'
                  : '🎤 따라 읽은 문장이 여기에 표시됩니다',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
