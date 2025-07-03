import 'package:flutter/material.dart';

class PromptExample extends StatelessWidget {
  final TextEditingController controller;
  const PromptExample({super.key, required this.controller});

  // 테두리에 그라디언트 색상을 적용하기 위한 커스텀 버튼
  Widget _gradientOutlineButton(String text) {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC1C1), Color(0xFFFFE1B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        margin: EdgeInsets.all(2.0), // 테두리 두께
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              // 예시 프롬프트 버튼 텍스트 입력 컨트롤러
              controller.text = text;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _gradientOutlineButton('오늘 가장 기억에 남는 순간은 무엇이었나요?'),
        SizedBox(height: 12),
        _gradientOutlineButton('오늘 힘들었던 일이나 고민이 있었나요?'),
        SizedBox(height: 12),
        _gradientOutlineButton('오늘 나를 웃게 만든 일은 무엇이었나요?'),
        SizedBox(height: 12),
        _gradientOutlineButton('내일을 위해 바라는 점이나 다짐이 있나요?'),
      ],
    );
  }
}
