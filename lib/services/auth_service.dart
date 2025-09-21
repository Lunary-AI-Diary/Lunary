import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 사용자가 스스로 구글 로그인을 취소했을 때 발생할 커스텀 오류
class GoogleSignInCanceledException implements Exception {
  @override
  String toString() => 'GoogleSignInCanceledException';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 로그인 메서드
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 회원가입 메서드
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    return credential;
  }

  // 구글 로그인
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // 사용자가 로그인 플로우를 취소한 경우
      throw GoogleSignInCanceledException();
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }
}
