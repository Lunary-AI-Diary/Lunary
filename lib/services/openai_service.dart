import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!; // 보안상 환경변수로 관리

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo", // 또는 gpt-4
        "messages": [
          {"role": "system", "content": "친절한 감정 일기 도우미입니다."},
          {"role": "user", "content": message},
        ],
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response: ${response.body}');
    }
  }
}
