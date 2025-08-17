/// 공통 헤더 위젯

import 'package:flutter/material.dart';

Widget buildHeader({required int step}) {
  return Column(
    children: [
      Image.asset(
        'assets/logo.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
      const SizedBox(height: 12),
      Text("회원가입", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      Text("3단계 중 $step 단계"),
    ],
  );
}
