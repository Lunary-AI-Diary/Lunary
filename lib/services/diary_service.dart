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
당신은 사용자의 하루를 요약해서 따뜻하고 감성적인 일기를 작성해주는 AI입니다.
입력받은 대화는 사용자와 AI 사이의 감정 나눔 대화입니다.
이를 바탕으로 아래 규칙을 지키며 사용자 입장에서의 일기를 작성하세요.

1. 일기는 사용자 입장에서 작성하세요.
2. 입력받은 사용자와 AI와의 대화를 바탕으로 사용자의 하루 일과, 감정 상태, 고민 등을 잘 요약하는 일기를 사용자를 대신해서 작성해 주세요.
3. "오늘 하루는 ..."처럼 하루를 정리하는 느낌으로 시작하세요.
4. 문체는 서정적이고 부드럽게, 1인칭 시점으로 작성하세요.
5. 종결어미는 "-이다", "-다"의 형식으로 작성하세요.
6. 마크다운 없는 줄글 형식으로 작성하세요.
7. 필요할 경우, 문단을 나누어 작성하세요.
8. 작성 분량은 가급적 500 ~ 1000자 이내로 하세요.
''';

    final userPrompt = "다음은 오늘 사용자와 AI의 대화 내용입니다:\n$transcript";

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
        'model': 'gpt-4o-mini', // 추후 모델 변경 가능
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

      await saveDiaryVersionToFirebase(diary, dateId);
    } else {
      throw Exception('일기 생성 실패: ${response.body}');
    }
  }

  // 일기 버전별로 Firestore에 저장 (versions 컬렉션 하위에 저장)
  Future<void> saveDiaryVersionToFirebase(String content, String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final versionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId)
        .collection('versions');

    await versionsRef.add({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 저장된 일기 버전 전체 Firestore에서 불러오기 (최신순)
  Future<List<Map<String, dynamic>>> fetchDiaryVersionsFromFirebase(
    String dateId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final versionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId)
        .collection('versions');

    final snapshot = await versionsRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // 최신 일기 버전만 불러오기
  Future<String?> fetchLatestDiaryFromFirebase(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final versionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId)
        .collection('versions');

    final snapshot = await versionsRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['content'] as String?;
    } else {
      return null;
    }
  }
}
