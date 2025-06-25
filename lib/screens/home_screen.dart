import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱 바 디자인
      appBar: AppBar(
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
            onPressed: () {
              // TODO: 검색 아이콘 버튼 클릭 시 동작 정의
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
      ),

      // 메인 화면 바디
      body: Center(child: Text('Home Screen')),
    );
  }
}
