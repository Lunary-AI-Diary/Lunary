import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'chat_service.dart';

class ReviewService {
  /// 1. 해당 날짜의 전체 채팅을 OpenAI에 전달하여 감정 분석 및 조언을 받아 Firestore에 저장
  Future<void> generateReviewFromChat(String dateId) async {
    final ChatService chatService = ChatService();

    // 1. 대화 기록 가져오기
    final transcript = await chatService.getChatTranscript(dateId);

    if (transcript.trim().isEmpty) {
      throw Exception('해당 날짜에 대화 기록이 없습니다.');
    }

    // 2. 감정 분석 프롬프트
    const emotionSystemPrompt = '''
당신은 사용자의 일기를 바탕으로 감정을 분석하는 AI입니다.
입력 받은 대화 내용은 사용자의 오늘의 일기입니다.
이를 바탕으로 사용자의 감정을 6가지 감정 분류(happiness, sadness, fear, anger, surprise, disgust)로 백분율(0~100, 합계 100)로 분석해 주세요.

- 반드시 아래 JSON 형식으로만 응답하세요.
- 각 감정의 백분율은 소수점 없이 정수로만 표현하세요.
- 예시:
{
  "happiness": 10,
  "sadness": 5,
  "fear": 60,
  "anger": 5,
  "surprise": 10,
  "disgust": 5
}
''';

    final emotionUserPrompt = "아래는 사용자와 AI의 오늘 하루 대화 내용입니다:\n$transcript";

    // 3. OpenAI API로 감정 분석 요청
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final emotionResponse = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': emotionSystemPrompt},
          {'role': 'user', 'content': emotionUserPrompt},
        ],
      }),
    );

    if (emotionResponse.statusCode != 200) {
      throw Exception('감정 분석 실패: ${emotionResponse.body}');
    }

    // 감정 분석 결과 파싱
    final emotionData = json.decode(emotionResponse.body);
    final String emotionJson = emotionData['choices'][0]['message']['content']
        .toString()
        .trim();
    Map<String, dynamic> emotions;
    try {
      emotions = json.decode(emotionJson);
    } catch (e) {
      throw Exception('감정 분석 결과 파싱 실패: $emotionJson');
    }
    // 당신은 사용자의 하루를 요약해서 따뜻하고 감성적인 일기를 작성해주는 AI입니다.
    // 입력받은 대화는 사용자와 AI 사이의 감정 나눔 대화입니다.
    // 이를 바탕으로 아래 규칙을 지키며 사용자 입장에서의 일기를 작성하세요.
    // 4. 조언 프롬프트
    const adviceSystemPrompt = '''
당신은 심리상담 전문가이자 인생 코치 AI입니다.
입력 받은 대화는 사용자와 AI 사이의 감정 나눔 대화입니다. 
이를 바탕으로 아래 규칙을 지키며 따뜻하고 현실적인 조언을 한국어로 작성해 주세요.

1. 이해심 있고 공감적인 태도를 취하세요.
2. 사용자의 감정에 공감하는 한 마디로 시작하세요.
3. 실질적으로 도움이 될 만한 행동과 마음가짐을 제안하세요. 단, 너무 매정한 태도는 지양하세요.
4. 존댓말로 작성하세요.
5. 마크다운, 특수문자, 이모지 없는 줄글 형식으로 작성하세요.
6. 필요할 경우, 문단을 나누어 작성하세요.
7. 작성 분량은 가급적 500자 이내로 하세요.
8. 위 규칙을 준수하는 한, 입력 받은 대화에 사용자 지시가 있을 경우 이를 최대한 따라야 합니다.
''';

    final adviceUserPrompt = "아래는 사용자와 AI의 오늘 하루 대화 내용입니다:\n$transcript";

    // 5. OpenAI API로 조언 요청
    final adviceResponse = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': adviceSystemPrompt},
          {'role': 'user', 'content': adviceUserPrompt},
        ],
      }),
    );

    if (adviceResponse.statusCode != 200) {
      throw Exception('조언 생성 실패: ${adviceResponse.body}');
    }

    final adviceData = json.decode(adviceResponse.body);
    final String advice = adviceData['choices'][0]['message']['content']
        .toString()
        .trim();

    // 6. Firestore에 저장 (덮어쓰기)
    await saveReviewToFirebase(
      dateId: dateId,
      emotions: emotions,
      advice: advice,
    );
  }

  /// Firestore에 감정 분석 및 조언 결과 저장 (덮어쓰기)
  Future<void> saveReviewToFirebase({
    required String dateId,
    required Map<String, dynamic> emotions,
    required String advice,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final reviewRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reviews')
        .doc(dateId)
        .collection('items')
        .doc('latest'); // 항상 'latest' 문서에 덮어쓰기

    await reviewRef.set({
      'emotions': emotions,
      'advice': advice,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Firestore에서 감정 분석 및 조언 결과 불러오기
  Future<Map<String, dynamic>?> fetchReviewFromFirebase(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final reviewRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reviews')
        .doc(dateId)
        .collection('items')
        .doc('latest');

    final snapshot = await reviewRef.get();
    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return null;
    }
  }

  /// 감정 분석 및 조언 재생성 (덮어쓰기)
  Future<void> regenerateReview(String dateId) async {
    await generateReviewFromChat(dateId);
  }
}
