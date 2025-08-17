// Step 2: 비밀번호 입력 화면

import 'package:flutter/material.dart';
import 'package:lunary/screens/auth/sign_up_step3.dart';
import 'package:lunary/widgets/auth/common_header.dart';
import 'package:lunary/widgets/auth/common_button.dart';
import 'package:lunary/widgets/auth/sign_up_colors.dart';

class SignUpStep2 extends StatefulWidget {
  final String name;
  final String email;

  const SignUpStep2({super.key, required this.name, required this.email});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscure = true;

  bool get _isPasswordValid {
    final pw = _pwController.text;
    final hasMinLength = pw.length >= 8;
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw);
    final hasNumber = RegExp(r'[0-9]').hasMatch(pw);
    return hasMinLength && hasSpecial && hasNumber;
  }

  bool get _isFormValid =>
      _isPasswordValid && _pwController.text == _confirmController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 600),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  buildHeader(step: 2),
                  const SizedBox(height: 20),
                  Text(
                    "사용하실 비밀번호를 입력하세요",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "비밀번호는 본인만 알 수 있도록 어렵게 만들어\n계정 보안을 강화하세요",
                    style: TextStyle(color: SignUpColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _pwController,
                    obscureText: _obscure,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      hintText: "비밀번호 생성",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscure,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: "비밀번호 확인",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• 비밀번호는 최소 8자여야 합니다",
                          style: TextStyle(
                            color: _pwController.text.length >= 8
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(
                          "• 비밀번호에는 숫자와 특수문자를 포함해야 합니다",
                          style: TextStyle(
                            color: _isPasswordValid ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          "• 비밀번호 일치",
                          style: TextStyle(
                            color:
                                _pwController.text == _confirmController.text &&
                                    _confirmController.text.isNotEmpty
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildBottomButtons(
                    context,
                    isEnabled: _isFormValid,
                    onContinue: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignUpStep3(
                            name: widget.name,
                            email: widget.email,
                            password: _pwController.text.trim(),
                          ),
                        ),
                      );
                      return;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
