import 'package:flutter/material.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/screens/home/introduce.dart';
import 'package:lunary/screens/home/prompt_example.dart';
import 'package:lunary/widgets/chat_input_field.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바
      appBar: const CommonAppBar(),

      // 홈 화면 디자인
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF5EF)),
        child: Column(
          children: [
            // 아래 ChatInputField를 아래로 보내기 위해 Introduce와 PromptExample이 있는 Column을 Expanded로 감쌈
            Expanded(
              // 키보드를 열었을 때 작아진 화면에서 스크롤이 가능하게 함. 이렇게 하면 오버플로우도 방지 할 수 있음.
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Introduce(),
                    SizedBox(height: 50),
                    PromptExample(),
                  ],
                ),
              ),
            ),
            const SafeArea(bottom: true, child: ChatInputField()),
          ],
        ),
      ),
    );
  }
}
