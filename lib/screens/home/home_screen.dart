import 'package:flutter/material.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/screens/home/introduce.dart';
import 'package:lunary/screens/home/prompt_example.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFFFFF5EF)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Introduce(), const PromptExample()],
            ),
          ],
        ),
      ),
    );
  }
}
