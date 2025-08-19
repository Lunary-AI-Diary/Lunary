// Step 3: 약관 동의 화면

import 'package:flutter/material.dart';
import 'package:lunary/screens/auth/login_screen.dart';
import 'package:lunary/widgets/auth/common_header.dart';
import 'package:lunary/widgets/auth/common_button.dart';
import 'package:lunary/services/auth_service.dart';
import 'package:lunary/widgets/common_error_dialog.dart';
import 'dart:developer';

class SignUpStep3 extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const SignUpStep3({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  bool _agreePrivacy = false;
  bool _agreeTerms = false;

  bool get _isFormValid => _agreePrivacy && _agreeTerms;

  Future<void> _signUp() async {
    try {
      await AuthService().signUpWithEmail(
        widget.email,
        widget.password,
        widget.name,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입 성공!')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      ); // 회원가입 후 로그인 화면으로 이동
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => CommonErrorDialog(message: '회원가입 실패'),
      );
      log('회원가입 실패: $e', name: 'sign_up_step3.dart');
    }
  }

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
                  buildHeader(step: 3),
                  const SizedBox(height: 20),
                  Text(
                    "서비스 이용 약관 및 개인정보 처리 방침",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "회원님의 개인정보는 안전하게 보관됩니다",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "제 정보는 어떻게 관리되나요?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("• 모든 AI 채팅과 일기 및 리뷰는 암호화된 데이터베이스에 보관됩니다"),
                        Text(
                          "• 회원님의 채팅 내용은 AI 학습에 이용되지 않으며 다른 사용자가 확인할 수 없습니다",
                        ),
                        Text("• 회원님의 개인정보는 서비스외 다른 용도로 절대 사용되거나 공유되지 않습니다"),
                        Text(
                          "• 언제든지 해당 서비스를 탈퇴할 수 있으며, 탈퇴 진행 시 회원님의 정보는 즉시 파기됩니다.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text("모든 서비스 이용 약관을 이해했으며 이에 동의합니다"),
                    value: _agreeTerms,
                    onChanged: (val) => setState(() => _agreeTerms = val!),
                  ),
                  CheckboxListTile(
                    title: Text("모든 개인정보 처리 방침을 이해했으며 이에 동의합니다"),
                    value: _agreePrivacy,
                    onChanged: (val) => setState(() => _agreePrivacy = val!),
                  ),
                  const SizedBox(height: 24),
                  buildBottomButtons(
                    context,
                    isEnabled: _isFormValid,
                    buttonText: "계정 생성",
                    onContinue: _isFormValid ? () => _signUp() : null,
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
