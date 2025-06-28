import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/screens/chat/chat_screen.dart';

void main() {
  testWidgets('ChatScreen 위젯 테스트', (WidgetTester tester) async {
    await dotenv.load(fileName: '.env');

    await tester.pumpWidget(MaterialApp(home: ChatScreen()));
  });
}
