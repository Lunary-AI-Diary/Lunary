import 'package:flutter/material.dart';
import 'package:lunary/services/auth_service.dart';
import 'package:lunary/widgets/common_error_dialog.dart';
import 'dart:developer';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// TODO: 회원가입 UI 개선 필요
class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    try {
      await AuthService().signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입 성공!')));
      Navigator.pop(context); // 회원가입 후 로그인 화면으로 이동
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => CommonErrorDialog(message: '회원가입 실패'),
      );
      log('회원가입 실패: $e', name: 'sign_up_screen.dart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: '이메일'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: '비밀번호'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _signUp, child: const Text('회원가입')),
          ],
        ),
      ),
    );
  }
}
