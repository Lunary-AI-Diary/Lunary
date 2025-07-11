import 'package:flutter/material.dart';
import 'package:lunary/widgets/calendar_dialog.dart';
import 'package:lunary/screens/account/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          // 달력 아이콘 클릭시, 달력 다이얼로그 표시
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => CalendarDialog(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          // 설정 버튼 클릭시 설정 기능 모달 창 표시
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 프로필 설정
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('프로필'),
                        onTap: () {
                          // TODO: 프로필 화면으로 이동
                        },
                      ),

                      // 테마 변경
                      ListTile(
                        leading: const Icon(Icons.color_lens),
                        title: const Text('테마'),
                        onTap: () {
                          // TODO: 테마 변경 화면으로 이동
                        },
                      ),

                      // 로그아웃
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('로그아웃'),
                        onTap: () async {
                          // Firebase 로그아웃
                          await FirebaseAuth.instance.signOut();

                          // 네비게이션 스택에서 첫 화면 제외 나머지 화면 제거(pop)
                          // 남은 첫 화면을 로그인 화면이로 이동
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst); // pop
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(), // 로그인 스크린 이동(pushReplacement: 이전화면으로 되돌아 갈 수 없음)
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
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
