import 'package:flutter/material.dart';
import 'package:lunary/services/review_service.dart';

class AiReviewTab extends StatefulWidget {
  final String dateId;
  const AiReviewTab({super.key, required this.dateId});

  @override
  State<AiReviewTab> createState() => _AiReviewTabState();
}

class _AiReviewTabState extends State<AiReviewTab> {
  Map<String, dynamic>? _review;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final review = await ReviewService().fetchReviewFromFirebase(
        widget.dateId,
      );
      setState(() {
        _review = review;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('오류: $_error', style: const TextStyle(color: Colors.red)),
      );
    }
    if (_review == null) {
      return const Center(
        child: Text('AI 리뷰가 아직 없습니다.', style: TextStyle(fontSize: 16)),
      );
    }

    final emotions = _review!['emotions'] as Map<String, dynamic>? ?? {};
    final advice = _review!['advice'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(24.0),
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
    );
  }

  String _emotionLabel(String key) {
    switch (key) {
      case 'anger':
        return '분노';
      case 'fear':
        return '두려움';
      case 'happiness':
        return '행복';
      case 'sadness':
        return '슬픔';
      case 'interest':
        return '관심';
      case 'surprise':
        return '놀라움';
      case 'disgust':
        return '혐오';
      case 'shame':
        return '수치심';
      default:
        return key;
    }
  }
}
