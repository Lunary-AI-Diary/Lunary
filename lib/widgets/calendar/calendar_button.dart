import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:lunary/screens/chat/chat_screen.dart';
import 'package:lunary/widgets/insufficient_chat_dialog.dart';

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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 대화기록 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE3F3FF),
                foregroundColor: Colors.blue.shade600,
                elevation: 1,
                shadowColor: Colors.blue.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                // 대화 기록이 없을때, 대화기록 버튼을 눌렀을 때 안내문
                if (count == 0) {
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
                            Icon(
                              Icons.info_outline,
                              color: Colors.pink,
                              size: 36,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "해당 날짜에 대화 기록이 없습니다.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$dateId 날짜의 대화를 시작할까요?",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
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
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(dateId: dateId),
                      ),
                    );
                  }
                  // 아니오를 누르면 안내창만 닫힘
                } else {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(dateId: dateId),
                    ),
                  );
                }
              },
              child: const Text('대화 기록'),
            ),

            // 일기보기 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE7F0),
                foregroundColor: Colors.pink.shade400,
                elevation: 1,
                shadowColor: Colors.pink.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                // 대화 기록 부족 안내문 표시
                if (count < 10) {
                  await showDialog(
                    context: context,
                    builder: (context) => const InsufficientChatDialog(),
                  );
                } else {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiaryScreen(dateId: dateId),
                    ),
                  );
                }
              },
              child: const Text('일기 보기'),
            ),
          ],
        );
      },
    );
  }
}
