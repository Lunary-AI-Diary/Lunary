import 'package:flutter/material.dart';

// 리뷰 및 조언 생성 테스트를 위한 임시 UI
// TODO: UI 디자인 개선할 것 -> 퍼센트 대신 그래프 등
class AiReviewTab extends StatelessWidget {
  final bool isLoading;
  final Map<String, dynamic>? review;
  final String dateId;

  const AiReviewTab({
    super.key,
    required this.isLoading,
    required this.review,
    required this.dateId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (review == null) {
      return const Center(
        child: Text('AI 리뷰가 아직 없습니다.', style: TextStyle(fontSize: 16)),
      );
    }

    final emotions = review!['emotions'] as Map<String, dynamic>? ?? {};
    final advice = review!['advice'] as String? ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          // 스크롤뷰 추가
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI 감정 분석 결과",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),
                ...emotions.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${_emotionLabel(e.key)}: ${e.value}%",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "AI의 오늘의 조언",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  advice,
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _emotionLabel(String key) {
    switch (key) {
      case 'happiness':
        return '행복';
      case 'sadness':
        return '슬픔';
      case 'fear':
        return '두려움';
      case 'anger':
        return '분노';
      case 'surprise':
        return '놀람';
      default:
        return key;
    }
  }
}
