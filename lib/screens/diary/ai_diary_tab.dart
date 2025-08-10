import 'package:flutter/material.dart';
import 'package:lunary/widgets/diary/diary_versions_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF8E1), // 연한 종이색 배경
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.orange.shade100, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 날짜와 이전 버전 버튼
                Row(
                  children: [
                    const Icon(
                      Icons.edit_calendar,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateId,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.pink.withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () =>
                          DiaryVersionsDialog.show(context, dateId),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text("이전 버전"),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // 제목
                Text(
                  diaryTitle ?? "제목 없음",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto', // 시스템 기본 폰트(손글씨 느낌 폰트가 있으면 교체)
                    fontSize: 28,
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                // 본문 (줄노트 느낌: Divider로 가로줄 효과)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Stack(
                      children: [
                        // 가로줄 효과
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final lineHeight = 32.0;
                            final lineCount =
                                (constraints.maxHeight / lineHeight).floor();
                            return Column(
                              children: List.generate(
                                lineCount,
                                (index) => Expanded(
                                  child: Divider(
                                    color: Colors.orange.shade50,
                                    thickness: 1,
                                    height: lineHeight,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // 본문 텍스트
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              diaryContent ?? "일기가 없습니다.",
                              style: const TextStyle(
                                fontFamily: 'Roboto', // 손글씨 느낌 폰트가 있으면 교체
                                fontSize: 18,
                                height: 2.0, // 줄 간격 넓게
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
