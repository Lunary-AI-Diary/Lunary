import 'package:flutter/material.dart';

class AiDiaryTab extends StatelessWidget {
  final bool isLoading;
  final String? diaryTitle;
  final String? diaryContent;
  final String dateId;

  const AiDiaryTab({
    super.key,
    required this.isLoading,
    required this.diaryTitle,
    required this.diaryContent,
    required this.dateId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diaryTitle ?? "제목 없음", // 제목 표시
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
          ),
          Text('$dateId 일기', style: const TextStyle(fontSize: 16.0)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Text(
                diaryContent ?? "일기가 없습니다.",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
