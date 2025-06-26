import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/screens/splash/splash_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const LunaryApp());
}

class LunaryApp extends StatelessWidget {
  const LunaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunary',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
