import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/services/openai_service.dart';

void main() {
  test('ChatService 테스트', () async {
    await dotenv.load(fileName: '.env');

    final chatService = ChatService();
    final response = await chatService.sendMessage('안녕!');
    print('AI 응답: $response');
  });
}
