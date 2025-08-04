import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';

class ShowDiaryFab extends StatelessWidget {
  final String dateId;
  final VoidCallback? onDiaryOpened;

  const ShowDiaryFab({super.key, required this.dateId, this.onDiaryOpened});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<bool>(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book, color: Colors.pink, size: 36),
                    const SizedBox(height: 16),
                    const Text(
                      "AI 채팅을 종료하고\n일기를 확인할까요?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "AI 채팅은 달력에서 선택해\n언제든 이어서 할 수 있습니다.",
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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DiaryScreen(dateId: dateId)),
            );
            if (onDiaryOpened != null) {
              onDiaryOpened!();
            }
          }
        },
        icon: const Icon(Icons.book),
        label: const Text("일기 보기"),
      ),
    );
  }
}
