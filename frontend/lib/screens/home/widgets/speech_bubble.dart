import 'package:flutter/material.dart';
import 'package:buds/screens/activity/activity_screen.dart';

class SpeechBubbleScreen extends StatelessWidget {
  const SpeechBubbleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.350,
      left: MediaQuery.of(context).size.width * 0.575,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivityScreen()),
          );
        },
        child: SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/icons/speech_bubble.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
              const Center(
                child: Text(
                  '안녕?\n오늘도\n화이팅이야',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
