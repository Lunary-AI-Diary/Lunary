import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:lunary/screens/chat/chat_screen.dart';
import 'package:lunary/widgets/no_chat_dialog.dart';
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
                // 대화 기록이 없을때, 대화기록 버튼을 눌렀을 때 안내문 표시
                if (count == 0) {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => NoChatDialog(dateId: dateId),
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
