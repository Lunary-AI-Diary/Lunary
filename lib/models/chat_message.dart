import 'package:cloud_firestore/cloud_firestore.dart';

// 채팅 메시지 모델 클래스
class ChatMessage {
  final String text;
  final DateTime? timestamp;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isUser,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isUser: data['role'] == 'user',
    );
  }
}
