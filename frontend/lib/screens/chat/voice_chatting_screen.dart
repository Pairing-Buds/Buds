import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/services/chat_service.dart';
import 'package:buds/screens/chat/chat_detail_screen.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceChattingScreen extends StatefulWidget {
  const VoiceChattingScreen({super.key});

  @override
  State<VoiceChattingScreen> createState() => _VoiceChattingScreenState();
}

class _VoiceChattingScreenState extends State<VoiceChattingScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ChatService _chatService = ChatService();
  final int userId = 4;

  bool _isMuted = false;
  bool _ttsPlaying = false;

  List<Map<String, dynamic>> _chatHistory = [];

  late NoiseMeter _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializeSTT();
    _checkMicPermission();
  }

  void _initializeTTS() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      _ttsPlaying = true;
      _stopListening();
      _startNoiseListener();
    });

    _tts.setCompletionHandler(() {
      _ttsPlaying = false;
      _noiseSubscription?.cancel();
      _noiseSubscription = null;
      if (!_isMuted) _startListening();
    });
  }
  Future<void> _checkMicPermission() async {
    final status = await Permission.microphone.status;

    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        _initializeSTT(); // 권한 허용되면 STT 초기화 시작
      } else {
        // 안내 메시지 띄우기
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('마이크 권한이 필요합니다')),
          );
        }
      }
    } else {
      _initializeSTT();
    }
  }

  void _initializeSTT() async {
    final available = await _speech.initialize(
    );

    if (available) {
      _startListening();
    } else {
    }
  }

  Future<void> _startListening() async {

    await Future.delayed(const Duration(milliseconds: 200));

    if (_speech.isListening || _isMuted || _ttsPlaying) return;

    final initialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          Future.delayed(const Duration(milliseconds: 500), _startListening);
        }
      },
      onError: (error) {
        if (error.permanent || error.errorMsg == 'error_speech_timeout') {
          Future.delayed(const Duration(milliseconds: 500), _startListening);
        }
      },
    );

    if (initialized) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _handleUserSpeech(result.recognizedWords.trim());
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: 'ko_KR',
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
        ),
      );
    } else {
    }
  }



  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  void _startNoiseListener() {
    // 이미 실행 중이면 다시 시작 안 함
    if (_noiseSubscription != null) return;

    _noiseMeter = NoiseMeter();

    try {
      _noiseSubscription = _noiseMeter.noise.listen((NoiseReading reading) {
        final dB = reading.meanDecibel;

        if (_ttsPlaying && dB > 88) {

          _tts.stop();
          _ttsPlaying = false;

          _noiseSubscription?.cancel();
          _noiseSubscription = null;

          if (_speech.isListening) _speech.stop();
          Future.delayed(const Duration(milliseconds: 300), _startListening);
        }
      });
    } catch (e) {
    }
  }




  void _handleUserSpeech(String text) async {
    setState(() {
      _chatHistory.add({"text": text, "isUser": true});
    });

    try {
      final response = await _chatService.sendMessage(
        message: text,
        isVoice: false,
      );

      setState(() {
        _chatHistory.add({"text": response, "isUser": false});
      });

      if (!_isMuted) {
        await _tts.speak(response);
      } else {
        _startListening();
      }
    } catch (e) {
      _startListening();
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);

    if (_isMuted) {
      _tts.stop();
      _speech.stop();
      _noiseSubscription?.cancel();
      _noiseSubscription = null;
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_speech.isListening) {
          _startListening();
        }
      });
    }
  }


  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.08),
            Image.asset('assets/images/marmet_head.png', width: screenHeight * 0.25),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _chatHistory[index];
                  return Align(
                    alignment: chat['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: chat['isUser'] ? const Color(0xfffef1d3) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(chat['text'] ?? '', style: const TextStyle(fontSize: 15)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Image.asset(
                      _isMuted ? 'assets/icons/mic_off.png' : 'assets/icons/mic_on.png',
                      width: screenWidth * 0.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _tts.stop();
                      _speech.stop();
                      _noiseSubscription?.cancel();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            initialHistory: _chatHistory.map((e) {
                              return {
                                'message': e['text'],
                                'is_user': e['isUser'] ?? false,
                                'created_at': DateTime.now().toIso8601String(),
                              };
                            }).toList(),
                          ),
                        ),
                            (route) => route.isFirst,
                      );
                    },
                    child: const Icon(Icons.close, size: 40, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
