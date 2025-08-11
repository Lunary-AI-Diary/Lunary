import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:lunary/screens/chat/chat_screen.dart';
import 'package:lunary/widgets/calendar/no_chat_dialog.dart';
import 'package:lunary/widgets/insufficient_chat_dialog.dart';

class CalendarButton extends StatelessWidget {
  final String dateId;
  final ChatService chatService;
  final bool isInCard; // 카드 안에서 쓸 때 true

  const CalendarButton({
    super.key,
    required this.dateId,
    required this.chatService,
    this.isInCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: chatService.getMessageCountStream(dateId),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 대화기록 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCard
                    ? const Color(0xFFF3F8FF)
                    : const Color(0xFFE3F3FF),
                foregroundColor: Colors.blue.shade600,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
            const SizedBox(width: 16),
            // 일기보기 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isInCard
                    ? const Color(0xFFFFF0F7)
                    : const Color(0xFFFFE7F0),
                foregroundColor: Colors.pink.shade400,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
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
