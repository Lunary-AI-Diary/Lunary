import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunary/screens/chat/chat_message.dart';

// 말풍선 위젯
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final alignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final bubbleDecoration = BoxDecoration(
      gradient: isUser
          ? const LinearGradient(
              colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: isUser ? null : const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(16),
    );

    final textStyle = TextStyle(
      fontSize: 14,
      color: isUser ? Colors.white : Colors.black87,
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: bubbleDecoration,
          child: Text(message.text, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            message.timestamp != null
                ? DateFormat('a hh:mm').format(message.timestamp!)
                : '',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
