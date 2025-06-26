import 'package:flutter_test/flutter_test.dart';
import 'package:lunary/services/chat_service.dart';

void main() {
  test('AI chat service test', () async {
    final chatService = ChatService();

    final result = await chatService.sendMessage('물고기는 왜 물에 살아?');
    print(result); // 결과를 콘솔에 출력
  });
}
