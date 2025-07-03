import 'package:flutter/material.dart';
import 'package:lunary/widgets/calendar_diaglog.dart';
import 'package:lunary/screens/diary/diary_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText; // 앱바 타이틀 텍스트

  const CommonAppBar({super.key, required this.titleText});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true, // 타이틀을 가운데 정렬
      backgroundColor: const Color(0xFFFFF5EF),
      actionsPadding: const EdgeInsets.only(right: 13),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),

      // 오른쪽 버튼
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => CalendarDialog(
                onDateSelected: (dateId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // TODO: 일기 상세 페이지 구현할 것(diary_screen.dart)
                      builder: (context) => DiaryScreen(dateId: dateId),
                    ),
                  );
                },
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: 설정 아이콘 버튼 클릭 시 동작 정의
          },
        ),
      ],

      flexibleSpace: Container(
        decoration: const BoxDecoration(
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
