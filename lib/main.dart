import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/screens/account/login_screen.dart';
// import 'package:lunary/screens/splash/splash_screen.dart';

void main() async {
  // 환경변수 불러오기
  await dotenv.load(fileName: '.env');

  // Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const LunaryApp());
}

class LunaryApp extends StatelessWidget {
  const LunaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunary',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
