import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:lunary/screens/chat/chat_screen.dart';

class ChatService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Firestore에 메시지 저장
  Future<void> _addMessage(String content, String role, String dateId) async {
    final uid = _auth.currentUser!.uid;

    final messageRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'role': role, // user 혹은 assistant
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // OpenAI API 호출
  Future<String> _getAIResponse(List<Map<String, String>> messages) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': messages, // 추후 모델 변경 가능
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      return reply.trim();
    } else {
      throw Exception('OpenAI 응답 오류: ${response.body}');
    }
  }

  /// 사용자 메시지 전송 후 AI 응답 받기
  Future<void> sendUserMessageAndGetAIResponse(
    String userMessage,
    String dateId,
  ) async {
    // 1. 사용자 메시지 저장
    await _addMessage(userMessage, 'user', dateId);

    // 2. 현재까지의 대화 불러오기
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    final messages = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'role': data['role'].toString(),
        'content': data['content'].toString(),
      };
    }).toList();

    // 3. OpenAI API에 메시지 전송
    final aiReply = await _getAIResponse(messages);

    // 4. AI 응답 메시지 저장
    await _addMessage(aiReply, 'assistant', dateId);
  }

  /// Firestore에서 실시간 메시지 불러오기
  Stream<List<ChatMessage>> getMessages(String dateId) {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage(
              text: data['content'] ?? '',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isUser: data['role'] == 'user',
            );
          }).toList(),
        );
  }

  // 해당 날짜의 모든 채팅 메시지를 '사용자: ~, AI: ~' 형식으로 문자열로 반환
  Future<String> getChatTranscript(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Firestore에서 해당 날짜(dateId)의 메시지 가져오기
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    // 메시지를 순서대로 문자열로 변환
    final transcript = snapshot.docs
        .map((doc) {
          final role = doc['role'] == 'user' ? '사용자' : 'AI';
          final content = doc['content'] ?? '';
          return "$role: $content";
        })
        .join('\n');

    return transcript;
  }
}
