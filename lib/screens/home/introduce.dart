import 'package:flutter/material.dart';

class Introduce extends StatelessWidget {
  const Introduce({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', width: 200, height: 200),
        SizedBox(height: 20),
        Text(
          '오늘 하루는 어땠나요?',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '하루 동안 당신이 느끼고 경험한 것을 말씀해 주세요.\n공감하며 이해심있는 태도로 듣겠습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
