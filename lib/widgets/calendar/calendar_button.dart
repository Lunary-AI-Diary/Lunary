import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';
import 'package:lunary/services/chat_service.dart';

class CalendarButton extends StatelessWidget {
  final String dateId;
  final ChatService chatService;

  const CalendarButton({
    super.key,
    required this.dateId,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: chatService.getMessageCountStream(dateId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFE7F0),
            foregroundColor: Colors.pink.shade400,
            elevation: 1,
            shadowColor: Colors.pink.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () async {
            if (count < 10) {
              await showDialog(
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
                        Icon(Icons.error_outline, color: Colors.pink, size: 36),
                        const SizedBox(height: 16),
                        const Text(
                          "대화기록이 부족해서\n일기를 만들 수 없습니다.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "일기는 최소 10개의 대화가 있어야 생성할 수 있습니다.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
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
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("확인"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DiaryScreen(dateId: dateId)),
              );
            }
          },
          child: const Text('일기 보기'),
        );
      },
    );
  }
}
