import 'package:flutter/material.dart';
import 'package:lunary/screens/diary/diary_screen.dart';
import 'package:lunary/widgets/chat/show_diary_dialog.dart';
import 'package:lunary/widgets/insufficient_chat_dialog.dart';

class ShowDiaryFab extends StatelessWidget {
  final String dateId;
  final int chatCount;

  const ShowDiaryFab({
    super.key,
    required this.dateId,
    required this.chatCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: FloatingActionButton(
        heroTag: 'showDiaryFab',
        onPressed: () async {
          // 대화 기록 부족 안내문 표시
          if (chatCount < 10) {
            await showDialog(
              context: context,
              builder: (context) => const InsufficientChatDialog(),
            );
          } else {
            // 일기 보기 안내문
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => const ShowDiaryDialog(),
            );
            if (result == true) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DiaryScreen(dateId: dateId)),
              );
            }
          }
        },
        child: const Icon(Icons.book),
        tooltip: '일기 보기',
      ),
    );
  }
}
