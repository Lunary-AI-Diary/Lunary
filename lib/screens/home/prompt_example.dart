import 'package:flutter/material.dart';

class PromptExample extends StatelessWidget {
  final TextEditingController controller;
  const PromptExample({super.key, required this.controller});

  // 테두리에 그라디언트 색상을 적용하기 위한 커스텀 버튼
  Widget _gradientOutlineButton(String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // 기본 최소 너비
        minHeight: 45, // 기본 최소 높이
        // maxWidth: 300, // 기본 최대 너비
      ),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC1C1), Color(0xFFFFE1B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            margin: const EdgeInsets.all(2.0),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    // maxLines: 2,
                    // overflow: TextOverflow.ellipsis,
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
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
      ),
    );
  }
}
