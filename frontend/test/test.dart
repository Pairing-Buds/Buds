// Package imports:
import 'package:buds/screens/login/widgets/login_main_widgets.dart';
import 'package:buds/screens/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buds/screens/chat/chat_detail_screen.dart';
import 'package:buds/screens/login/login_main.dart';
import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
class testscreen extends StatelessWidget {
  const testscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.primary,
      body: SafeArea(
        child:LayoutBuilder(
          builder: (context, constraints){

          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final double titleScale = width < 360 ? 0.8 : 1.0;
          final double imaageScale = width < 360 ? 3.0 : 2.5;
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child : Column(children: [
            const SizedBox (height: 16),
            Transform.scale(scale: titleScale,
            child: const MainTitleWidget(),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen(),
                  ),
                );
              },
              child: const ChatContainer(),
            ),
            const SizedBox(height: 8),
            Flexible(flex:4,
            child: Center(child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder : (context) => const MainScreen(),
                ),
                );
              },
              child: Image.asset('asset/images/newmarmetmain.png',
              scale: imaageScale,
              fit: BoxFit.contain,
              ),
            ),
            ),
            ),
            const SizedBox(height: 8),
            const StartButton(),
            const SizedBox(height:8),
            const LoginButton(),
            const SizedBox(height: 8),
          ],
          ),
          );
          },
          ),
      ),
      );
  }
}            
