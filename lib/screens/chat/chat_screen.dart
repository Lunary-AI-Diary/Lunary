import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lunary/widgets/common_app_bar.dart';
import 'package:lunary/widgets/chat_input_field.dart';
import 'package:lunary/services/chat_service.dart';
import 'package:lunary/models/chat_message.dart';
import 'package:lunary/screens/chat/chat_bubble.dart';
import 'package:lunary/screens/chat/show_diary_fab.dart';
import 'package:lunary/screens/chat/reset_fab.dart';
import 'package:lunary/utils/date_utils.dart';
import 'package:lunary/widgets/common_error_dialog.dart';

// 채팅 화면
class ChatScreen extends StatefulWidget {
  // HomeScreen에서 ChatInputField에 받아 전송된 메세지를 initialMessage라 칭함
  final String? initialMessage;

  final String dateId;

  const ChatScreen({super.key, this.initialMessage, required this.dateId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  bool _isLoading = false; // 메세지 전송 버튼에 표시되는 로딩
  bool _showTypingIndicator = false; // AI 응답 생성 중에 말풍선에 표시되는 로딩

  @override
  void initState() {
    super.initState();
    // initialMessage가 있으면 자동 전송 후 AI 응답 반환
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      Future.microtask(() async {
        setState(() {
          _isLoading = true;
          _showTypingIndicator = true;
        });
        try {
          await _chatService.sendUserMessageAndGetAIResponse(
            widget.initialMessage!,
            widget.dateId,
          );
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => CommonErrorDialog(message: '메세지 송수신 실패'),
          );
          log('메세지 송수신 실패: $e', name: 'chat_screen.dart');
        } finally {
          setState(() {
            _isLoading = false;
            _showTypingIndicator = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(titleText: 'AI 채팅'),
      backgroundColor: const Color(0xFFFFF5EF),
      body: SafeArea(
        child: Column(
          children: [
            // 채팅 날짜 표시 (상단 중앙)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${formatDateIdToKorean(widget.dateId)} 채팅",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            // 채팅 메시지 영역
            Expanded(
              // StreamBuilder: 비동기 데이터(스트림)가 변경될 때 마다 UI 자동 갱신
              // 여기서 사용하는 스트림은 List<ChatMessage> 타입 객체
              child: StreamBuilder<List<ChatMessage>>(
                // dateId(오늘 날짜)에 해당하는 스트림 데이터 반환
                // 이곳에 새로운 채팅 데이터가 올 때 마다 UI 업데이트
                stream: _chatService.getMessages(widget.dateId),
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
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      80,
                    ), // 하단 패딩 80
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

                // 입력한 메세지 전송 및 AI 응답 반환
                try {
                  await _chatService.sendUserMessageAndGetAIResponse(
                    text,
                    widget.dateId,
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 일기 보기 버튼
          StreamBuilder<int>(
            stream: _chatService.getMessageCountStream(widget.dateId),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return ShowDiaryFab(dateId: widget.dateId, chatCount: count);
            },
          ),
          const SizedBox(width: 10),
          // 채팅 리셋 버튼
          ResetFab(dateId: widget.dateId, chatService: _chatService),
        ],
      ),
    );
  }
}
