import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';
import 'package:lunary/screens/diary/diary_versions_dialog.dart';

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

  // 일기 버전을 불러오는 메서드
  Future<void> _showVersionsDialog(BuildContext context) async {
    final diaryService = DiaryService();
    final versions = await diaryService.fetchDiaryVersionsFromFirebase(dateId);

    // 가장 최근 일기(현재 탭에 보이는 것)는 제외
    final previousVersions = versions.length > 1
        ? versions.sublist(1).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    showDialog(
      context: context,
      builder: (context) =>
          DiaryVersionsDialog(previousVersions: previousVersions),
    );
  }

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
            diaryTitle ?? "제목 없음",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
          ),
          Text('$dateId 일기', style: const TextStyle(fontSize: 16.0)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.pink.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: () => _showVersionsDialog(context),
              icon: const Icon(Icons.history),
              label: const Text("이전 버전 보기"),
            ),
          ),
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
