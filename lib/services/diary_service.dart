import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lunary/services/chat_service.dart';
import 'dart:convert';

class DiaryService {
  // 일기와 제목을 함께 생성
  Future<void> generateDiaryFromChat(String dateId) async {
    final ChatService chatService = ChatService();

    // 1. 대화 기록 가져오기
    final transcript = await chatService.getChatTranscript(dateId);

    if (transcript.trim().isEmpty) {
      throw Exception('해당 날짜에 대화 기록이 없습니다.');
    }

    // 2. 일기 본문 생성 프롬프트
    const diarySystemPrompt = '''
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

    final diaryUserPrompt = "다음은 오늘 사용자와 AI의 대화 내용입니다:\n$transcript";

    // 3. OpenAI API로 일기 본문 생성
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final diaryResponse = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': diarySystemPrompt},
          {'role': 'user', 'content': diaryUserPrompt},
        ],
      }),
    );

    if (diaryResponse.statusCode != 200) {
      throw Exception('일기 생성 실패: ${diaryResponse.body}');
    }

    final diaryData = json.decode(diaryResponse.body);
    final String diaryContent = diaryData['choices'][0]['message']['content']
        .toString()
        .trim();

    // 4. 일기 제목 생성 프롬프트
    const titleSystemPrompt = '''
당신은 감성적이고 창의적인 일기 제목을 만들어주는 AI입니다.
입력받은 내용은 사용자의 오늘 하루 일기입니다.
일기에 나타난 하루 일과와 핵심 감정, 주제를 잘 드러내는 15자 이내의 감성적인 제목을 한국어로 만들어 주세요.
마침표, 따옴표, 특수문자 없이 제목만 출력하세요.
''';

    final titleUserPrompt =
        "아래는 오늘의 일기 내용입니다. 이 일기에 어울리는 제목을 만들어 주세요.\n\n$diaryContent";

    final titleResponse = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': titleSystemPrompt},
          {'role': 'user', 'content': titleUserPrompt},
        ],
      }),
    );

    if (titleResponse.statusCode != 200) {
      throw Exception('일기 제목 생성 실패: ${titleResponse.body}');
    }

    final titleData = json.decode(titleResponse.body);
    final String diaryTitle = titleData['choices'][0]['message']['content']
        .toString()
        .trim();

    // 5. Firestore에 저장 (content, title 함께)
    await saveDiaryVersionToFirebase(
      title: diaryTitle,
      content: diaryContent,
      dateId: dateId,
    );
  }

  // 일기 버전별로 Firestore에 저장 (versions 컬렉션 하위에 저장)
  Future<void> saveDiaryVersionToFirebase({
    required String title,
    required String content,
    required String dateId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    final versionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId)
        .collection('versions');

    await versionsRef.add({
      'title': title,
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
  Future<Map<String, dynamic>?> fetchLatestDiaryFromFirebase(
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
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      return null;
    }
  }

  // 마지막 일기 생성 이후로 대화가 업데이트(추가/수정/삭제) 되었는지 확인
  Future<bool> isChatUpdatedAfterLastDiary(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("사용자 인증 필요");

    // 1. 최신 일기 생성 시각 가져오기
    final versionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diaries')
        .doc(dateId)
        .collection('versions');

    final diarySnapshot = await versionsRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (diarySnapshot.docs.isEmpty) {
      // 일기가 없으면 "일기 재생성"이 아니라, "일기 생성"이 필요한 것이므로 false 반환
      return false;
    }

    final lastDiaryCreatedAt =
        diarySnapshot.docs.first['createdAt'] as Timestamp;

    // 2. 일기 생성 이후에 추가된 메시지가 있는지 확인
    final messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(dateId)
        .collection('messages');

    // `마지막 일기 timestamp < 채팅 timestamp`인 채팅이 하나라도 있으면 채팅 기록이 업데이트 된 것으로 간주
    final updatedMessages = await messagesRef
        .where('timestamp', isGreaterThan: lastDiaryCreatedAt)
        .limit(1)
        .get();

    // 쿼리 결과, 하나라도 있으면 true
    return updatedMessages.docs.isNotEmpty;
  }
}
