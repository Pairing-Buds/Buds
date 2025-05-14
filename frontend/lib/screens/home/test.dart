import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as riv;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: riv.RiveAnimation.asset(
                'assets/animations/sea.riv',
                fit: BoxFit.cover,
              ),
            ),
            Center(child: Text('Rive Test', style: TextStyle(fontSize: 40))),
          ],
        ),
      ),
    );
  }
}
