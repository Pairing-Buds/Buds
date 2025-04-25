import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';
import 'package:buds/config/theme.dart';

class VoiceChattingScreen extends StatelessWidget {
  const VoiceChattingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.1),

            Center(
              child: Image.asset(
                'assets/images/marmet_head.png',
                width: screenHeight * 0.25,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              '오늘은 힘든 하루였구나.\n나랑 더 얘기해볼래?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: screenHeight * 0.32),

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xfffef1d3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.7,
                  ),
                  child: const Text(
                    '집에 있는데 집에 가고 싶어',
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),

 SizedBox(height: screenHeight * 0.05),

            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: 마이크 동작
                    },
                    child: Image.asset(
                      'assets/icons/mic_off.png',
                      width: screenWidth * 0.12,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatDetailScreen(
                            message: '집에 있는데 집에 가고 싶어',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
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
