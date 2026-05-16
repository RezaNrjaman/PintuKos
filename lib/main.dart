import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PintuKosApp());
}

class PintuKosApp extends StatelessWidget {
  const PintuKosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PintuKos',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
