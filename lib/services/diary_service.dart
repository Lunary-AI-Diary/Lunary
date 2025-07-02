import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/services/chat_service.dart';
import 'dart:convert';

class DiaryService {
  // OpenAI API를 통해 오늘의 대화를 바탕으로 일기 생성
  Future<void> generateDiaryFromChat(String dateId) async {
    final ChatService chatService = ChatService();

    // 1. 대화 기록 가져오기
    final transcript = await chatService.getChatTranscript(dateId);

    // 대화 기록이 없으면 일기 생성 중단
    if (transcript.trim().isEmpty) {
      throw Exception('해당 날짜에 대화 기록이 없습니다.');
    }

    // 2. 프롬프트 구성
    // TODO: 프롬프트 엔지니어링 하기
    const systemPrompt = '''
당신은 사용자의 하루를 따뜻하게 요약해서 감성적인 일기 형식으로 작성해주는 AI입니다.
입력받은 대화는 사용자와 AI 사이의 감정 나눔입니다. 이를 바탕으로 다음 조건을 만족하는 일기를 작성하세요:

1. "오늘 하루는 ..."처럼 하루를 정리하는 느낌으로 시작하세요.
2. 감정, 분위기, 고민 등을 공감 어린 시선으로 정리하세요.
3. 문체는 서정적이고 부드럽게, 1인칭 시점으로 작성하세요.
4. 줄글 형식(마크다운 없이)으로 작성하세요. 또한 문단을 나누어 작성하세요.
5. 작성 분량은 가급적 300~500자 이내로 하세요.
''';

    final userPrompt = "다음은 오늘 사용자와의 대화 내용입니다:\n$transcript";

    // 3. OpenAI API 호출
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo', // 추후 모델 변경 가능
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String diary = data['choices'][0]['message']['content']
          .toString()
          .trim();

      await saveDiaryToFirebase(diary, dateId);
    } else {
      throw Exception('일기 생성 실패: ${response.body}');
    }
  }

  // 생성된 일기 Firebase에 저장
  Future<void> saveDiaryToFirebase(String content, String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final diaryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId);

    await diaryRef.set({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 저장된 일기 Firebase에서 불러오기
  Future<String?> fetchDiaryFromFirebase(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final diaryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId);

    final docSnapshot = await diaryRef.get();

    if (docSnapshot.exists) {
      return docSnapshot.data()?['content'] as String?;
    } else {
      return null; // 해당 날짜에 일기가 없을 경우
    }
  }
}
