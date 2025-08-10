import 'package:flutter/material.dart';
import 'package:lunary/services/auth_service.dart';
import 'package:lunary/screens/auth/sign_up_screen.dart';
import 'package:lunary/screens/home/home_screen.dart';

// 채팅 테스트
// import 'package:lunary/screens/chat/chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 이메일, 비밀번호 입력값을 받을 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 로그인 처리 함수
  Future<void> _login() async {
    try {
      await AuthService().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // 로그인 성공 시 처리
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 성공!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(), // 로그인 성공시 홈 스크린으로 이동
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 로고 아이콘
                Image.asset('assets/logo.png', height: 80, width: 80),
                const SizedBox(height: 16),
                const Text(
                  'Lunary',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '나만의 작은 AI 일기장',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '환영합니다!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '친절하고 따뜻한 AI 일기장 루나리와 함께 \n내면의 세계를 그려보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // 로그인 폼
                Form(
                  child: Column(
                    children: [
                      // 이메일 입력창
                      TextField(
                        controller: _emailController, // 컨트롤러 연결
                        keyboardType: TextInputType.emailAddress, // 이메일 키보드
                        autofillHints: const [AutofillHints.email], // 자동완성 힌트
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: '이메일',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 비밀번호 입력창
                      TextField(
                        controller: _passwordController, // 컨트롤러 연결
                        obscureText: true, // 입력값 가리기
                        keyboardType: TextInputType.visiblePassword, // 비밀번호 키보드
                        autofillHints: const [
                          AutofillHints.password, // 자동완성 힌트
                        ],
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: const Icon(Icons.remove_red_eye_outlined),
                          hintText: '비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('아이디/비밀번호 찾기'),
                  ),
                ),
                const SizedBox(height: 8),
                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _login, // 로그인 함수 연결
                    style:
                        ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFFF8CBA),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => null,
                          ),
                        ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5D8C), Color(0xFFFFC56B)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          '로그인',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("계정이 없으신가요?"),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.pink),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('다른 방법으로 로그인'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Google'),
                        onPressed: () {}, // TODO: 구글 연동 로직 구현
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          minimumSize: const Size(0, 48), // 높이 통일
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.facebook),
                        label: const Text('Facebook'),
                        onPressed: () {}, // TODO: 페이스북 연동 로직 구현
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          minimumSize: const Size(0, 48), // 높이 통일
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // TODO: 약관 이동 페이지 만들기
                Column(
                  children: [
                    const Text.rich(
                      TextSpan(
                        text: '회원가입 진행 시, 귀하는 해당 ',
                        children: [
                          TextSpan(
                            text: '서비스 정책',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' 및 '),
                          TextSpan(
                            text: '개인정보 이용 약관',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' 에 동의한 것으로 간주합니다. '),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
