import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';
import 'package:lunary/widgets/common_app_bar.dart';

/// 일기를 보여주는 화면
/// - 일기가 없으면 자동 생성
/// - FloatingActionButton을 눌러 일기 재생성 가능
class DiaryScreen extends StatefulWidget {
  final String dateId; // yyyy-MM-dd 형식의 날짜 ID

  const DiaryScreen({super.key, required this.dateId});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryService _diaryService = DiaryService(); // 일기 관련 서비스 객체
  String? _diaryContent; // 현재 화면에 보여질 일기 내용
  bool _isLoading = true; // 로딩 상태 여부

  /// 화면 초기화 시 일기 불러오기 또는 생성
  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  /// Firestore에서 일기를 불러오거나 없으면 생성하는 메서드
  Future<void> _loadDiary() async {
    setState(() => _isLoading = true);

    try {
      // Firestore에서 일기 데이터 가져오기
      String? existingDiary = await _diaryService.fetchDiaryFromFirebase(
        widget.dateId,
      );

      // 일기가 없을 경우 새로 생성
      if (existingDiary == null) {
        await _diaryService.generateDiaryFromChat(widget.dateId);
        existingDiary = await _diaryService.fetchDiaryFromFirebase(
          widget.dateId,
        );
      }

      // 화면에 일기 반영
      setState(() {
        _diaryContent = existingDiary ?? "일기를 불러올 수 없습니다.";
        _isLoading = false;
      });
    } catch (e) {
      // 오류 발생 시 예외 메시지 표시
      setState(() {
        _diaryContent = "오류 발생: $e";
        _isLoading = false;
      });
    }
  }

  /// 일기를 재생성하여 Firestore에 덮어쓰는 메서드
  Future<void> _regenerateDiary() async {
    setState(() => _isLoading = true);

    try {
      // 새 일기 생성 및 저장
      await _diaryService.generateDiaryFromChat(widget.dateId);

      // 새 일기 다시 불러오기
      final updatedDiary = await _diaryService.fetchDiaryFromFirebase(
        widget.dateId,
      );

      // UI에 반영
      setState(() {
        _diaryContent = updatedDiary ?? "일기를 불러올 수 없습니다.";
        _isLoading = false;
      });

      // 성공 메시지 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("일기가 새로 생성되었습니다.")));
    } catch (e) {
      // 오류 처리 및 메시지 표시
      setState(() {
        _isLoading = false;
        _diaryContent = "오류 발생: $e";
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱 바
      appBar: const CommonAppBar(titleText: '일기 보기'),

      // 본문 영역
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 선택한 날짜 표시
                    Text(
                      "선택된 날짜: ${widget.dateId}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          bottom: 120,
                        ), // 플로팅 버튼 높이만큼 여백을 줘, 플로팅 버튼에 가려줘도 스크롤 내릴 수 있도록 함
                        child: Text(
                          _diaryContent ?? "일기가 없습니다.",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),

      // 오른쪽 하단에 일기 재생성용 FloatingActionButton 배치
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null // 로딩 중일 땐 버튼 비활성화
            : _regenerateDiary, // 눌렀을 때 일기 재생성
        icon: const Icon(Icons.refresh),
        label: const Text("일기 재생성"),
      ),
    );
  }
}
