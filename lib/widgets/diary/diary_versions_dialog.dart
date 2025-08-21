import 'package:flutter/material.dart';
import 'package:lunary/services/diary_service.dart';

class DiaryVersionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> previousVersions;

  const DiaryVersionsDialog({super.key, required this.previousVersions});

  // 일기 이전 버전 불러오기
  static Future<void> show(BuildContext context, String dateId) async {
    final diaryService = DiaryService();
    final versions = await diaryService.fetchDiaryVersionsFromFirebase(dateId);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFFFF5EF),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: Colors.pink, size: 36),
            const SizedBox(height: 16),
            const Text(
              "이전 버전의 일기",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: previousVersions.isEmpty
                  ? const Center(child: Text("이전 버전의 일기가 없습니다."))
                  : ListView.separated(
                      itemCount: previousVersions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, idx) {
                        final v = previousVersions[idx];
                        final versionNumber = previousVersions.length - idx;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink.shade50,
                            child: Text(
                              "v.$versionNumber",
                              style: const TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(v['title'] ?? "제목 없음"),
                          subtitle: Text(
                            v['content'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: const Color(0xFFFFF5EF),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 28,
                                    horizontal: 24,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v['title'] ?? "제목 없음",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          v['content'] ?? "",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.pink,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("닫기"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("닫기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
