import 'package:flutter/material.dart';

// 감정별 색상 매핑
const Map<String, Color> emotionColors = {
  '행복': Colors.amber,
  '슬픔': Colors.blue,
  '두려움': Colors.deepPurple,
  '분노': Colors.redAccent,
  '놀람': Colors.teal,
};

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

    final rawEmotions = review!['emotions'];
    final Map<String, dynamic> emotions = rawEmotions is Map
        ? rawEmotions.map((k, v) => MapEntry(k.toString(), v))
        : {};
    final advice = review!['advice'] as String? ?? '';

    // 감정 순서 지정
    final emotionOrder = ['happiness', 'sadness', 'fear', 'anger', 'surprise'];

    return Container(
      color: const Color(0xFFFFF5EF), // 배경색
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
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
                  const SizedBox(height: 24),
                  // 감정 분석 그래프 네모 박스
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // <-- 배경색을 흰색으로 변경
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.orange.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: emotionOrder.map((key) {
                        final label = _emotionLabel(key);
                        final value = (emotions[key] ?? 0).toDouble();
                        final color = emotionColors[label] ?? Colors.grey;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: value / 100,
                                      child: Container(
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  "${value.toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    "AI의 오늘의 조언",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // <-- 배경색을 흰색으로 변경
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.orange.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      advice,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
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
