import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  // 사용자가 메시지를 전송했을 때 호출되는 콜백 함수
  // 외부에서 이 위젯을 사용할 때 메시지 처리 ChatInputField 생성자로 연결할 수 있음
  final void Function(String)? onSend;

  final bool isLoading;

  final TextEditingController? controller; // 예시 프롬프트 버튼 텍스트 입력 컨트롤러

  const ChatInputField({
    super.key,
    this.onSend,
    this.isLoading = false,
    this.controller,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode(); // 자동 커서 포커스

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // 위젯이 빌드된 후 자동 포커스 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  // 입력된 텍스트를 전송 처리하는 함수
  // - 입력값이 비어 있지 않으면 외부 콜백(onSend)을 호출(onSend 함수는 ChatInputField 인스턴스를 만들때 생성자로 받는 매개변수임)
  // - 이후 입력창을 초기화
  void _handleSend() {
    final text = _controller.text.trim(); // trim(): 앞뒤 공백 제거
    if (text.isNotEmpty) {
      widget.onSend?.call(text); // null-safe 호출. null이 아닐 때만 실행
      _controller.clear(); // 입력창 비우기
    }
  }

  @override
  Widget build(BuildContext context) {
    // 채팅창
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        // TextField 디자인
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), // 둥근 모서리
                border: Border.all(color: Colors.orange.shade100), // 테두리 색
              ),
              child: Center(
                child: TextField(
                  controller: _controller, // 예시 프롬프트 버튼 텍스트 입력 컨트롤러
                  focusNode: _focusNode, // FocusNode 연결
                  decoration: const InputDecoration(
                    border: InputBorder.none, // TextField의 기본 테두리 없애기
                    hintText: "대화를 시작해볼까요?",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onSubmitted: (_) => _handleSend(), // 키보드 제출 시 전송
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 전송 or 로딩 버튼
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFC1C1), Color(0xFFFFE1B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: widget.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _handleSend,
                  ),
          ),
        ],
      ),
    );
  }
}
