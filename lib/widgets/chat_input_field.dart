import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  // 사용자가 메시지를 전송했을 때 호출되는 콜백 함수입니다.
  // 외부에서 이 위젯을 사용할 때 메시지 처리 로직을 여기에 연결할 수 있습니다.
  final void Function(String)? onSend;

  const ChatInputField({super.key, this.onSend});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  // 사용자가 입력한 텍스트를 관리하는 컨트롤러입니다.
  // TextField의 현재 입력값에 접근하거나 초기화할 때 사용됩니다.
  final TextEditingController _controller = TextEditingController();

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
    return SafeArea(
      // 기기 하단 영역(iPhone 홈 바 등) 침범 방지
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent, // 배경은 투명하게 유지
        child: Row(
          children: [
            // 입력창(TextField)이 포함된 둥근 박스
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // 둥근 모서리
                  border: Border.all(color: Colors.orange.shade100), // 테두리 색
                ),
                child: Center(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none, // TextField의 기본 테두리 없애기
                      hintText: "Share your thoughts and feelings...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onSubmitted: (_) => _handleSend(), // 키보드 제출 시 전송
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 전송 버튼
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
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
