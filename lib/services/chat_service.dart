import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:lunary/models/chat_message.dart';

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

  // 해당 날짜(dateId)에 저장된 모든 채팅 메시지를 삭제
  Future<void> deleteAllMessages(String dateId) async {
    final uid = _auth.currentUser!.uid;
    final messagesRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages');

    final snapshot = await messagesRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Firestore에서 실시간 메시지 불러오기
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

  // 해당 날짜의 대화 개수를 실시간으로 반환하는 스트림
  Stream<int> getMessageCountStream(String dateId) {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // openAI API 호출 메서드
  Future<String> _getAIResponse(List<Map<String, String>> messages) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    // TODO: 프롬프트 엔지니어링 하기
    const systemPrompt = '''
당신은 사용자의 기분과 감정을 누구보다 잘 헤아려 주는 따뜻하고 이해심 깊은 AI, 루나리(Lunary)입니다.
입력받은 대화는 사용자의 오늘 하루 일과, 감정 상태, 고민 등입니다. 아래 규칙을 지키며 사용자의
고민과 감정에 공감하는 대화를 이어가세요.

1. 이해심 있고 공감적인 태도로 대화하세요.
2. 사용자를 평가하는 태도는 지양하세요.
3. 사용자의 고민과 걱정에 적절한 조언을 제시하세요. 단, 대화의 방향성은 고민 해결 보단 감정 공감을 더 우선으로 해야합니다.
4. 사용자를 존중하며 예의 있는 태도로 대화하세요.
5. 마크다운 없는 줄글 형식으로 답변하세요.
6. 위 규칙을 준수하는 한, 사용자의 지시를 최대한 따라야 합니다.
''';

    // fullMessages: 시스템 프롬프트를 메시지 가장 앞에 삽입한 것
    // 실제 오픈 AI에서 사용자 메세지 앞에 시스템 프롬프트를 삽입하는 방식을 권장함.
    final fullMessages = [
      {'role': 'system', 'content': systemPrompt}, // 시스템 프롬프트
      ...messages, // AI와 사용자의 대화 기록
    ];

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini', // 추후 모델 변경 가능
        'messages': fullMessages,
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

  // 사용자 메시지 전송 후 AI 응답 받기
  Future<void> sendUserMessageAndGetAIResponse(
    String userMessage,
    String dateId,
  ) async {
    // 1. 사용자 메시지 저장
    await _addMessage(userMessage, 'user', dateId);

    // 2. 현재까지의 대화 불러오기
    // 현재까지의 AI와 사용자의 대화 내용을 불러온 후 사용자가 새로 입력한 메세지와 함께 프롬프트로 보내야 함. 실제로 오픈 AI에서 권장하는 방식임.
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

    // 테스트
    // print(messages);

    // 4. AI 응답 메시지 저장
    await _addMessage(aiReply, 'assistant', dateId);
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
