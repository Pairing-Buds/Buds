import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/services/chat_service.dart';
import 'package:buds/screens/chat/chat_detail_screen.dart';

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

  bool _isListening = false;
  bool _isMuted = false;
  bool _isSpeaking = false;

  List<Map<String, dynamic>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _initializeSTT();
  }

  void _handleResponse(String userInput) async {
    try {
      final String response = await _chatService.sendMessage(
        userId: userId,
        message: userInput,
        isVoice: true,
      );

      setState(() {
        _chatHistory.add({"text": response, "isUser": false});
      });

      if (!_isMuted) {
        if (_speech.isListening) {
          await _speech.stop();
        }

        await _tts.speak(response);

        _tts.setCompletionHandler(() {
          if (!_isMuted && !_speech.isListening) {
            _startListening();
          }
        });
      }

    } catch (e) {
      debugPrint('챗봇 응답 실패: $e');
    }
  }


  Future<void> _initializeTTS() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
      _startListening();
    });

    _tts.setStartHandler(() {
      setState(() => _isSpeaking = true);
      _stopListening();
    });
  }

  Future<void> _initializeSTT() async {
    await _speech.initialize();
    _startListening();
  }

  void _startListening() {
    if (_isMuted || _isSpeaking || _isListening) return;

    _speech.listen(
      localeId: 'ko_KR',
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _handleUserSpeech(result.recognizedWords);
        }
      },
    );
    setState(() => _isListening = true);
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _handleUserSpeech(String userInput) async {
    setState(() {
      _chatHistory.add({"text": userInput, "isUser": true});
    });

    try {
      final botReply = await _chatService.sendMessage(
        userId: userId,
        message: userInput,
        isVoice: true,
      );

      setState(() {
        _chatHistory.add({"text": botReply, "isUser": false});
      });

      if (!_isMuted) {
        await _tts.speak(botReply);
      } else {
        _startListening();
      }
    } catch (e) {
      debugPrint("🛑 챗봇 응답 실패: $e");
      _startListening();
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      _tts.stop();
      _speech.stop();
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
                    alignment:
                    chat['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
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
                      width: screenWidth * 0.12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _tts.stop();
                      _speech.stop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            initialHistory: _chatHistory.map((e) {
                              return {
                                'message': e['text'],        // 키 맞춰주기
                                'is_user': e['isUser'] ?? false,
                                'created_at': DateTime.now().toIso8601String(),
                              };
                            }).toList(),
                          ),
                        ),
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
