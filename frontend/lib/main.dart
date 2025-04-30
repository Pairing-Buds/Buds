import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'config/theme.dart';
// import 'screens/login/login_screen.dart';
import 'screens/login/login_main.dart';
import 'package:provider/provider.dart';
import 'providers/agree_provider.dart';
import 'providers/character_provider.dart';
import 'package:buds/screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgreementProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'buds',
      theme: appTheme,
      home: const MainScreen(),
      //home: const LoginMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
