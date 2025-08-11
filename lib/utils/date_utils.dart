import 'package:intl/intl.dart';

// yyyy-mm-dd 형식의 dateId를 "년 월 일"으로 바꿔주는 메소드
String formatDateIdToKorean(String dateId) {
  try {
    final date = DateTime.parse(dateId);
    return DateFormat('yyyy년 M월 d일').format(date);
  } catch (_) {
    return dateId;
  }
}
