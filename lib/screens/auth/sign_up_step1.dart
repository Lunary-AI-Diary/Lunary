// Step 1: 이름, 이메일 입력 화면

import 'package:flutter/material.dart';
import 'package:lunary/screens/auth/sign_up_step2.dart';
import 'package:lunary/widgets/auth/common_header.dart';
import 'package:lunary/widgets/auth/common_button.dart';
import 'package:lunary/widgets/auth/sign_up_colors.dart';

class SignUpStep1 extends StatefulWidget {
  const SignUpStep1({super.key});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool get _isFormValid =>
      _nameController.text.isNotEmpty && _emailController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF), // 배경색 추가
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          // 스크롤 뷰로 감쌈
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 600), // 최소 높이 지정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                buildHeader(step: 1),
                const SizedBox(height: 20),
                Text(
                  "이름과 이메일을 입력해 주세요",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "이메일은 로그인 시 필요하며, 이름은 프로필에 표시됩니다.",
                  style: TextStyle(color: SignUpColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: "이름",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "이메일",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildBottomButtons(
                  context,
                  isEnabled: _isFormValid,
                  onContinue: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpStep2()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
