import 'package:flutter/material.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:lunary/widgets/chat/reset_dialog.dart';

class ResetFab extends StatelessWidget {
  final String dateId;
  final ChatService chatService;

  const ResetFab({super.key, required this.dateId, required this.chatService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: FloatingActionButton(
        heroTag: 'resetChat',
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => const ResetDialog(),
          );
          if (confirm == true) {
            await chatService.deleteAllMessages(dateId);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('채팅 기록이 삭제되었습니다.')));
          }
        },
        child: const Icon(Icons.refresh),
        tooltip: '채팅 기록 리셋',
      ),
    );
  }
}
