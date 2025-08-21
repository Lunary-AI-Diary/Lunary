import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunary/models/chat_message.dart';

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
      color: isUser ? null : Colors.white, // AI 버블 배경
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: Radius.circular(isUser ? 18 : 4),
        bottomRight: Radius.circular(isUser ? 4 : 18),
      ),
      boxShadow: isUser
          ? []
          : [
              BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
      border: isUser
          ? null
          : Border.all(color: Colors.orange.shade100, width: 1.2),
    );

    final textStyle = TextStyle(
      fontSize: 15,
      color: isUser ? Colors.white : Colors.black87,
      fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 2),
                child: Image.asset(
                  'assets/logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: bubbleDecoration,
              child: Text(message.text, style: textStyle),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: isUser ? 0 : 44,
            right: isUser ? 8 : 0,
          ),
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
