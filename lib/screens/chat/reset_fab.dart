import 'package:flutter/material.dart';
import 'package:lunary/services/chat_service.dart';

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
                    Icon(Icons.refresh, color: Colors.pink, size: 36),
                    const SizedBox(height: 16),
                    const Text(
                      "채팅 기록을 모두 삭제할까요?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "삭제된 채팅 기록은 복구할 수 없습니다.",
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
