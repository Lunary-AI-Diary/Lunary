import 'package:flutter/material.dart';

class PromptExample extends StatelessWidget {
  const PromptExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 프롬프트 버튼 1
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(300, 45),
            side: BorderSide(width: 2.0, color: Color(0xFFFDAC9C)),
            alignment: Alignment.centerLeft,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '예시 프롬프트 1',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),

        // 프롬프트 버튼 2
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(300, 45),
            side: BorderSide(width: 2.0, color: Color(0xFFFDAC9C)),
            alignment: Alignment.centerLeft,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '예시 프롬프트 2',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),

        // 프롬프트 버튼 3
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(300, 45),
            side: BorderSide(width: 2.0, color: Color(0xFFFDAC9C)),
            alignment: Alignment.centerLeft,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '예시 프롬프트 3',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),

        // 프롬프트 버튼 4
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(300, 45),
            side: BorderSide(width: 2.0, color: Color(0xFFFDAC9C)),
            alignment: Alignment.centerLeft,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '예시 프롬프트 4',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
