import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/login/widgets/chat_bubble.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({Key? key, required this.onInitializationComplete})
    : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ChatMessage> _chatMessages = [];
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onInitializationComplete();
      }
    });

    _initializeApp();
    _setupChatMessages();
  }

  void _setupChatMessages() {
    // 채팅 메시지 준비
    _chatMessages.addAll([
      _ChatMessage(
        '안녕! 나는 마멋이야✨',
        Colors.brown,
        true,
        'assets/icons/characters/newmarmet.png',
      ),
      _ChatMessage(
        '우리 함께 버즈에서 좋은 습관을 만들어보자!',
        Colors.green,
        false,
        'assets/icons/characters/frog.png',
      ),
      _ChatMessage(
        '서로의 성장을 응원해주는 거야~!',
        Colors.orange,
        true,
        'assets/icons/characters/fox.png',
      ),
      _ChatMessage(
        '귀여운 친구들이 기다리고 있어요!',
        Colors.blue,
        false,
        'assets/icons/characters/duck.png',
      ),
    ]);

    // 채팅 메시지 순차적으로 보여주기
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          // 첫 번째 메시지 표시
          _chatMessages[0].visible = true;
        });

        // 두 번째 메시지
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _chatMessages[1].visible = true;
            });
          }
        });

        // 세 번째 메시지
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _chatMessages[2].visible = true;
            });
          }
        });

        // 네 번째 메시지
        Future.delayed(const Duration(milliseconds: 1700), () {
          if (mounted) {
            setState(() {
              _chatMessages[3].visible = true;
            });
          }
        });

        // 로고 표시
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (mounted) {
            setState(() {
              _showLogo = true;
            });
          }
        });

        // 애니메이션 완료 후 전환
        Future.delayed(const Duration(milliseconds: 3000), () {
          if (mounted && !_controller.isCompleted) {
            _controller.forward();
          }
        });
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // AuthProvider 초기화
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      if (!mounted) return;
    } catch (e) {
      debugPrint('앱 초기화 오류: $e');
      // 오류가 발생해도 스플래시 화면 완료 후 앱으로 진행
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 배경 무늬 효과
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/icons/characters/newmarmet.png',
                repeat: ImageRepeat.repeat,
                width: 80,
                height: 80,
              ),
            ),
          ),

          // 배경에 동물 캐릭터 이미지 (흐릿하게)
          Positioned(
            right: -30,
            bottom: -10,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/icons/characters/newmarmet.png',
                width: 180,
                height: 180,
              ),
            ),
          ),

          // 채팅 버블들
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 상단 여백
                  const SizedBox(height: 100),

                  // 채팅 메시지들
                  for (var message in _chatMessages)
                    if (message.visible)
                      AnimatedOpacity(
                        opacity: message.visible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ChatBubble(
                            color: message.color,
                            text: message.text,
                            isLeft: message.isLeft,
                            iconPath: message.iconPath,
                            backgroundColor:
                                message.isLeft
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.cardBackground.withOpacity(0.9),
                          ),
                        ),
                      ),

                  const Spacer(),

                  // 로고
                  AnimatedOpacity(
                    opacity: _showLogo ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/characters/newmarmet.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Buds',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                            fontFamily: 'GmarketSans',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 채팅 메시지 데이터 클래스
class _ChatMessage {
  final String text;
  final Color color;
  final bool isLeft;
  final String iconPath;
  bool visible;

  _ChatMessage(
    this.text,
    this.color,
    this.isLeft,
    this.iconPath, {
    this.visible = false,
  });
}
