import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lunary/screens/auth/login_screen.dart';
import 'package:lunary/widgets/common_error_dialog.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFFFF5EF),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle, size: 56, color: Colors.orange),
            const SizedBox(height: 18),
            Text(
              user?.displayName ?? '이름 없음',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '이메일 없음',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text(
                  "회원 탈퇴",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: const Color(0xFFFFF5EF),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.pink,
                              size: 38,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "정말로 탈퇴하시겠습니까?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "계정 정보와 데이터가 모두 삭제됩니다.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade300,
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("아니오"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      "탈퇴",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await user?.delete();
                      if (context.mounted) {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            CommonErrorDialog(message: '계정 탈퇴 실패'),
                      );
                      log('계정 탈퇴 실패: $e', name: 'profile_dialog.dart');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
