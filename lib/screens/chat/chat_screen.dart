import 'package:flutter/material.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/widgets/chat_input_field.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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

// 채팅 화면
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  bool _isLoading = false; // 메세지 전송 버튼에 표시되는 로딩
  bool _showTypingIndicator = false; // AI 응답 생성 중에 말풍선에 표시되는 로딩

  final String dateId = _getTodayDateId();

  // 현재 날짜 정보 반환 - 데이터 베이스에 채팅 기록을 날짜별로 저장하기 위함
  static String _getTodayDateId() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 채팅 메시지 영역
            Expanded(
              // StreamBuilder: 비동기 데이터(스트림)가 변경될 때 마다 UI 자동 갱신
              // 여기서 사용하는 스트림은 List<ChatMessage> 타입 객체
              child: StreamBuilder<List<ChatMessage>>(
                // dateId(특정 날짜)에 해당하는 스트림 데이터 반환
                // 이곳에 새로운 채팅 데이터가 올 때 마다 UI 업데이트
                stream: _chatService.getMessages(dateId),
                builder: (context, snapshot) {
                  // snapshot: 스트림의 현재 상태와 데이터를 담은 매개변수
                  // ConnectionState.waiting: 데이터가 아직 도착하지 않은 상태
                  // 로딩 표시(CircularProgressIndicator)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages =
                      snapshot.data ??
                      []; // 데이터가 있으면 message에 가져오고 없으면(null) 빈 리스트 저장

                  // 메세지를 스크롤 가능한 UI로 보여줌
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _showTypingIndicator
                        ? messages.length + 1
                        : messages.length,
                    itemBuilder: (context, index) {
                      if (_showTypingIndicator && index == messages.length) {
                        // 마지막에 typing bubble 표시
                        return ChatBubble(
                          message: ChatMessage(
                            text: "답변을 작성 중이에요...",
                            timestamp: null,
                            isUser: false,
                          ),
                        );
                      } else {
                        return ChatBubble(message: messages[index]);
                      }
                    },
                  );
                },
              ),
            ),

            // 채팅 입력창
            // 입력 필드 (로딩 상태 전달)
            ChatInputField(
              isLoading: _isLoading,
              onSend: (text) async {
                setState(() {
                  _isLoading = true;
                  _showTypingIndicator = true;
                });

                try {
                  await _chatService.sendUserMessageAndGetAIResponse(
                    text,
                    dateId,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
                } finally {
                  setState(() {
                    _isLoading = false;
                    _showTypingIndicator = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

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

  // 시간 포맷을 위해 intl 패키지에 DateFormat 클래스를 대신 사용하기로 함.
  // 혹시 몰라서 남겨 둠
  //
  // String _formatTime(DateTime time) {
  //   final hour = time.hour > 12 ? time.hour - 12 : time.hour;
  //   final minute = time.minute.toString().padLeft(2, '0');
  //   final period = time.hour >= 12 ? '오후' : '오전';
  //   return '$period $hour:$minute';
  // }
}
