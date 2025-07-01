import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key, required this.dateId});

  final dynamic dateId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('선택된 날짜: $dateId')));
  }
}
