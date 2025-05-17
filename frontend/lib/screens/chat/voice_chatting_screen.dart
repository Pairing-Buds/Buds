// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_tts/flutter_tts.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/services/chat_service.dart';

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
  final ScrollController _scrollController = ScrollController();

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

  Future<void> _playRemoteAudio(String audioPath) async {
    final baseUrl = dotenv.env['FASTAPI_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('❌ FASTAPI_URL 누락');
      return;
    }

    final url = '$baseUrl$audioPath';
    print('🔊 재생할 URL: $url');

    try {
      final player = AudioPlayer();

      // 🔍 재생 상태 먼저 listen() 등록
      player.onPlayerStateChanged.listen((state) {
        print('🎧 현재 상태: $state');
      });

      // 🔊 설정
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(1.0);

      // ▶️ 재생 시도
      print('📢 오디오 재생 시도 전');
      await player.play(UrlSource(url));
      print('📢 오디오 재생 시도 후');
    } catch (e) {
      print('❌ 오디오 재생 오류: $e');
    }
  }

  Future<void> _checkMicPermission() async {
    final status = await Permission.microphone.status;

    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        print('🎤 마이크 권한 허용됨');
        _initializeSTT();
      } else {
        print('❌ 마이크 권한 거부됨');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('마이크 권한이 필요합니다')),
          );
        }
      }
    } else {
      print('✅ 마이크 권한 이미 있음');
      _initializeSTT();
    }
  }

  void _initializeSTT() async {
    final available = await _speech.initialize(
      onStatus: (status) => print('🎙️ STT 상태: $status'),
      onError: (error) => print('❌ STT 오류: $error'),
    );

    print('✅ STT 초기화 성공 여부: $available');
    if (available) {
      _startListening();
    } else {
      print('🚫 STT 초기화 실패: 마이크 권한 확인 필요');
    }
  }

  Future<void> _startListening() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_speech.isListening || _isMuted || _ttsPlaying) return;

    final initialized = await _speech.initialize(
      onStatus: (status) {
        print('🎙️ STT 상태: $status');
        if (status == 'done' || status == 'notListening') {
          Future.delayed(const Duration(milliseconds: 500), _startListening);
        }
      },
      onError: (error) {
        print('❌ STT 오류: $error');
        if (error.permanent || error.errorMsg == 'error_speech_timeout') {
          Future.delayed(const Duration(milliseconds: 500), _startListening);
        }
      },
    );

    if (initialized) {
      print("✅ STT 시작");
      _speech.listen(
        onResult: (result) {
          print("🎧 onResult called!");
          print("👉 인식된 문장: '${result.recognizedWords}'");
          print("✅ FinalResult 여부: ${result.finalResult}");

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
      print("❌ STT 초기화 실패");
    }
  }

  void _stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  void _startNoiseListener() {
    if (_noiseSubscription != null) return;

    _noiseMeter = NoiseMeter();

    try {
      _noiseSubscription = _noiseMeter.noise.listen((NoiseReading reading) {
        final dB = reading.meanDecibel;
        print("📈 현재 소음 dB: $dB");

        if (_ttsPlaying && dB > 94) {
          print("🎤 사용자 말 감지됨! → TTS 중단 → STT 시작");

          _tts.stop();
          _ttsPlaying = false;

          _noiseSubscription?.cancel();
          _noiseSubscription = null;

          if (_speech.isListening) _speech.stop();
          Future.delayed(const Duration(milliseconds: 300), _startListening);
        }
      });
    } catch (e) {
      print("❌ NoiseMeter 오류: $e");
    }
  }

  void _handleUserSpeech(String text) async {
    setState(() {
      _chatHistory.add({"text": text, "isUser": true});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    try {
      final response = await _chatService.sendMessage(
        message: text,
        isVoice: true,
      );

      final messageText = response['text'];
      final audioPath = response['audioPath'];

      setState(() {
        _chatHistory.add({"text": messageText, "isUser": false});
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      if (!_isMuted && audioPath != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _playRemoteAudio(audioPath);
        });
      } else if (!_isMuted) {
        await _tts.speak(messageText);
      } else {
        _startListening();
      }
    } catch (e) {
      print("❌ 오류: $e");
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
    _scrollController.dispose();
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
                controller: _scrollController,
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
                      Navigator.pop(context);
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
