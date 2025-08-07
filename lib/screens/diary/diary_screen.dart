import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/screens/diary/ai_diary_tab.dart';
import 'package:lunary/screens/diary/ai_review_tab.dart';
import 'package:lunary/screens/diary/report_tab.dart';
import 'package:lunary/screens/diary/diary_fab.dart';

// 일기를 보여주는 화면
class DiaryScreen extends StatefulWidget {
  final String dateId; // yyyy-MM-dd 형식의 날짜 ID

  const DiaryScreen({super.key, required this.dateId});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  final DiaryService _diaryService = DiaryService();
  String? _diaryTitle;
  String? _diaryContent;
  bool _isDiaryLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {}); // 탭이 바뀔 때마다 리빌드
    });
    _loadDiary();
    _checkAndShowRegenerateDialog(); // 추가: 입장 시 안내문 체크
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // DiaryScreen 관련 메서드
  // 1. Firestore에서 일기를 불러오거나 없으면 생성하는 메서드
  Future<void> _loadDiary() async {
    setState(() => _isDiaryLoading = true);

    try {
      // Firestore에서 일기 데이터 가져오기 (Map 반환)
      final latestDiary = await _diaryService.fetchLatestDiaryFromFirebase(
        widget.dateId,
      );

      // 일기가 없을 경우 새로 생성
      if (latestDiary == null) {
        await _diaryService.generateDiaryFromChat(widget.dateId);
        // 생성 후 다시 불러오기
        final generatedDiary = await _diaryService.fetchLatestDiaryFromFirebase(
          widget.dateId,
        );
        setState(() {
          _diaryTitle = generatedDiary?['title'] ?? "제목 없음";
          _diaryContent = generatedDiary?['content'] ?? "일기를 불러올 수 없습니다.";
          _isDiaryLoading = false;
        });
        return;
      }

      // 화면에 일기 반영
      setState(() {
        _diaryTitle = latestDiary['title'] ?? "제목 없음";
        _diaryContent = latestDiary['content'] ?? "일기를 불러올 수 없습니다.";
        _isDiaryLoading = false;
      });
    } catch (e) {
      setState(() {
        _diaryTitle = "오류 발생";
        _diaryContent = "오류 발생: $e";
        _isDiaryLoading = false;
      });
    }
  }

  // 2. 일기를 재생성하는 메서드
  Future<void> _regenerateDiary() async {
    setState(() => _isDiaryLoading = true);

    try {
      await _diaryService.generateDiaryFromChat(widget.dateId);
      final updatedDiary = await _diaryService.fetchLatestDiaryFromFirebase(
        widget.dateId,
      );
      setState(() {
        _diaryTitle = updatedDiary?['title'] ?? "제목 없음";
        _diaryContent = updatedDiary?['content'] ?? "일기를 불러올 수 없습니다.";
        _isDiaryLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("일기가 새로 생성되었습니다.")));
    } catch (e) {
      setState(() {
        _isDiaryLoading = false;
        _diaryTitle = "오류 발생";
        _diaryContent = "오류 발생: $e";
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  // 3. 마지막 일기 생성 이후 채팅이 변경되었으면 안내문 표시
  Future<void> _checkAndShowRegenerateDialog() async {
    // 잠깐 대기: context가 완전히 준비된 후 실행
    await Future.delayed(const Duration(milliseconds: 300));
    final needRegenerate = await _diaryService.isChatUpdatedAfterLastDiary(
      widget.dateId,
    );
    if (needRegenerate) {
      if (!mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFF5EF),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.pink, size: 36),
                const SizedBox(height: 16),
                const Text(
                  "마지막 일기 생성 이후로\n채팅 기록이 변경되었습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "일기를 재생성할까요?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("아니오"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("예"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      if (result == true) {
        await _regenerateDiary();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(titleText: '일기 보기'),
      body: Column(
        children: [
          // 탭바: "AI 일기", "AI 리뷰", "리포트" 세개 탭
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.pink,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.pink,
              tabs: const [
                Tab(text: "AI 일기"),
                Tab(text: "AI 리뷰"),
                Tab(text: "리포트"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // AI 일기
                AiDiaryTab(
                  isLoading: _isDiaryLoading,
                  diaryTitle: _diaryTitle,
                  diaryContent: _diaryContent,
                  dateId: widget.dateId,
                ),
                // AI 리뷰
                const AiReviewTab(),
                // 리포트
                const ReportTab(),
              ],
            ),
          ),
        ],
      ),

      // _tabController.index에 따라 플로팅액션버튼이 다르게 표시.
      // 0: "일기 재생성" 버튼
      // 1: "리뷰 재생성" 버튼
      // 2: "리포트 재생성" 버튼
      floatingActionButton: DiaryFloatingActionButton(
        // 인덱스
        tabIndex: _tabController.index,

        // 일기 재생성 플로팅 버튼에서 사용
        isDiaryLoading: _isDiaryLoading,
        onRegenerateDiary: _regenerateDiary,

        // 리뷰 재생성 플로팅 버튼에서 사용
        // isReviewLoading: _isReviewLoading,
        // onRegenerateReview: _regenerateReview,

        // 리포트 재성성 플로팅 버튼에서 사용
        // isReportLoading: _isReportLoading,
        // onRegenerateReport: _regenerateReport,
      ),
    );
  }
}
