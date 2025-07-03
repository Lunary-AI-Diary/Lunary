import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/widgets/common_app_bar.dart';

// 일기 생성 기능 테스트용 임시 UI
// TODO: UI 디자인 개선하기
class DiaryScreen extends StatefulWidget {
  final String dateId;

  const DiaryScreen({super.key, required this.dateId});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryService _diaryService = DiaryService();
  String? _diaryContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    try {
      // 일기가 존재하지 않으면 생성
      String? existingDiary = await _diaryService.fetchDiaryFromFirebase(
        widget.dateId,
      );

      if (existingDiary == null) {
        await _diaryService.generateDiaryFromChat(widget.dateId);
        existingDiary = await _diaryService.fetchDiaryFromFirebase(
          widget.dateId,
        );
      }

      setState(() {
        _diaryContent = existingDiary ?? "일기를 불러올 수 없습니다.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _diaryContent = "오류 발생: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(titleText: '일기 보기'),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "선택된 날짜: ${widget.dateId}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(_diaryContent ?? "일기가 없습니다."),
                  ],
                ),
              ),
      ),
    );
  }
}
