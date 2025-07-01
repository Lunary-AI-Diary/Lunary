import 'package:flutter/material.dart';
import 'package:lunary/widgets/calendar_diaglog.dart';
import 'package:lunary/screens/diary/diary_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 하트 아이콘 + 앱 이름 텍스트
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.favorite, color: Color(0xFFFDAC9C)),
            onPressed: null,
          ),

          // 하트와 텍스트 사이 간격을 지정하기 위한 SizedBox
          SizedBox(width: 4), // 원하는 만큼 숫자 조절
          Text(
            'Lunary',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: false,
      backgroundColor: Color(0xFFFFF5EF),

      // 오른쪽 버튼
      actionsPadding: EdgeInsets.only(right: 13),
      actions: <Widget>[
        // 달력 버튼
        IconButton(
          icon: Icon(Icons.calendar_month),

          // 달력 버튼 클릭 시, 달력 다이얼로그(CalendarDialog) 호출
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => CalendarDialog(
                onDateSelected: (date) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // TODO: 일기 상세 페이지 구현할 것(diary_screen.dart)
                      builder: (context) => DiaryScreen(date: date),
                    ),
                  );
                },
              ),
            );
          },
        ),
        // 설정 버튼
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // TODO: 설정 아이콘 버튼 클릭 시 동작 정의
          },
        ),
      ],

      // 앱 바 아래 테두리 설정
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFFFEDD5), width: 3.5),
          ),
        ),
      ),
    );
  }

  // 앱 바 크기를 권장크기(KToolbarHeight)로 설정
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
