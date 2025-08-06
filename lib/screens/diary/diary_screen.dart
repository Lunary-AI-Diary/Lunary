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
  String? _diaryTitle; // 추가
  String? _diaryContent;
  bool _isDiaryLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {}); // 탭이 바뀔 때마다 리빌드(탭 마다 플로팅 액션 버튼이 다르기 때문)
    });
    _loadDiary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // DiaryScreen 관련 메서드
  // TODO: 현재는 일기 불러오기, 생성, 재생성, 저장 기능만 있음.
  // TODO: 리뷰 불러오기, 생성, 재생성, 저장 메서드 만들기
  // TODO: 리포트 불러오기, 생성, 재생성, 저장 메서드 만들기

  // Firestore에서 일기를 불러오거나 없으면 생성하는 메서드
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

  // 일기를 재생성하는 메서드
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
                  diaryTitle: _diaryTitle, // 추가
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

      // 플로팅 액션 버튼 로직
      // TODO: 현재는 일기 재생성만 구현되어 있음. 리뷰 재생성, 리포트 재생성 기능 구현할 것.

      // _tabController.index에 따라 플로팅액션버튼이 다르게 표시.
      // 0: "일기 재생성" 버튼
      // 1: "리뷰 재생성" 버튼
      // 2: "리포트 재생성" 버튼
      floatingActionButton: DiaryFloatingActionButton(
        tabIndex: _tabController.index,
        isDiaryLoading: _isDiaryLoading,
        // isReviewLoading: _isReviewLoading,
        // isReportLoading: _isReportLoading,
        onRegenerateDiary: _regenerateDiary,
        // onRegenerateReview: _regenerateReview,
        // onRegenerateReport: _regenerateReport,
      ),
    );
  }
}
