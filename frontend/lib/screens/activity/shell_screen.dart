import 'dart:math';
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
  double _similarity = 0.0;
  ActivityQuoteModel? _quote;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _fetchQuote();
  }

  Future<void> _initSpeech() async {
    _hasSpeech = await _speech.initialize();
    setState(() {});
  }

  Future<void> _fetchQuote() async {
    try {
      final quote = await ActivityService().fetchDailyQuote();
      setState(() {
        _quote = quote;
      });
    } catch (_) {}
  }

  double _calcSimilarity() {
    if (_quote == null || _recognizedText.isEmpty) return 0;
    return similarity(_quote!.sentence, _recognizedText);
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _similarity = _calcSimilarity());
    } else {
      _recognizedText = '';
      _similarity = 0;
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) _similarity = _calcSimilarity();
          });
        },
        localeId: 'ko_KR',
      );
    }
    setState(() => _isListening = !_isListening);
  }

  void _sendReadText() async {
    final success = await ActivityService().submitSttResult(
      originalSentenceText: _quote?.sentence ?? "",
      userSentenceText: _quote?.sentence ?? "",
    );
    if (success) _showSuccessModal();
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("인증 성공"),
        content: const Text("선물로 편지지 5장을 드립니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home_screen'),
            child: const Text("확인"),
          ),
        ],
      ),
    );
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(_quote?.sentence ?? '명언을 불러오는 중...'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleListening,
              child: Text(_isListening ? '듣기 중지' : '따라 읽기'),
            ),
            if (_recognizedText.isNotEmpty)
              Text('🗣️ $_recognizedText'),
          ],
        ),
      ),
    );
  }
}

// 🔹 Levenshtein 거리 (한국어 비교)
double similarity(String s1, String s2) {
  final dist = jamoLevenshtein(s1, s2);
  final maxLen = max(s1.length, s2.length);
  return maxLen == 0 ? 1 : (maxLen - dist) / maxLen;
}

int jamoLevenshtein(String s1, String s2) {
  if (s1.length < s2.length) return jamoLevenshtein(s2, s1);
  if (s2.isEmpty) return s1.length;

  List<double> prev = List.generate(s2.length + 1, (i) => i.toDouble());
  for (var i = 0; i < s1.length; i++) {
    List<double> curr = [i + 1];
    for (var j = 0; j < s2.length; j++) {
      final cost = (s1[i] == s2[j]) ? 0 : 1;
      curr.add(min(curr[j] + 1, min(prev[j + 1] + 1, prev[j] + cost)));
    }
    prev = curr;
  }
  return prev.last.toInt();
}
