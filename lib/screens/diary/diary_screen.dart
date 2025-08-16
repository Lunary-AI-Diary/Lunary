import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';
import 'package:lunary/services/review_service.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/screens/diary/ai_diary_tab.dart';
import 'package:lunary/screens/diary/ai_review_tab.dart';
import 'package:lunary/screens/diary/diary_fab.dart';
import 'package:lunary/widgets/diary/diary_regenerate_dialog.dart';

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
  final ReviewService _reviewService = ReviewService();
  String? _diaryTitle;
  String? _diaryContent;
  bool _isDiaryLoading = true;

  Map<String, dynamic>? _review;
  bool _isReviewLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {}); // 탭이 바뀔 때마다 리빌드
    });
    _loadDiary();
    _loadReview();
    _checkAndShowRegenerateDialog();
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
        builder: (context) => const DiaryRegenerateDialog(),
      );
      if (result == true) {
        // 일기 재생성
        await _regenerateDiary();

        // 리뷰 재생성
        await _regenerateReview();
      }
    }
  }

  // 4. 리뷰 불러오기 (없으면 자동 생성)
  Future<void> _loadReview() async {
    setState(() => _isReviewLoading = true);

    try {
      final latestReview = await _reviewService.fetchReviewFromFirebase(
        widget.dateId,
      );

      if (latestReview == null) {
        await _reviewService.generateReviewFromChat(widget.dateId);
        final generatedReview = await _reviewService.fetchReviewFromFirebase(
          widget.dateId,
        );
        setState(() {
          _review = generatedReview;
          _isReviewLoading = false;
        });
        return;
      }

      setState(() {
        _review = latestReview;
        _isReviewLoading = false;
      });
    } catch (e) {
      setState(() {
        _review = {'advice': '오류 발생: $e', 'emotions': {}};
        _isReviewLoading = false;
      });
    }
  }

  // 5. 리뷰 재생성 메서드
  Future<void> _regenerateReview() async {
    setState(() => _isReviewLoading = true);

    try {
      await _reviewService.regenerateReview(widget.dateId);
      final updatedReview = await _reviewService.fetchReviewFromFirebase(
        widget.dateId,
      );
      setState(() {
        _review = updatedReview;
        _isReviewLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("리뷰가 새로 생성되었습니다.")));
    } catch (e) {
      setState(() {
        _isReviewLoading = false;
        _review = {'advice': '오류 발생: $e', 'emotions': {}};
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
          // 탭바: "AI 일기", "AI 리뷰"
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
                AiReviewTab(
                  isLoading: _isReviewLoading,
                  review: _review,
                  dateId: widget.dateId,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: DiaryFab(
        tabIndex: _tabController.index,
        isDiaryLoading: _isDiaryLoading,
        isReviewLoading: _isReviewLoading,
        onRegenerateDiary: _regenerateDiary,
        onRegenerateReview: _regenerateReview,
      ),
    );
  }
}
