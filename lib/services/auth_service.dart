import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 로그인 메서드
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // TODO: 회원가입 로직에 이름 추가, 비밀번호 확인 추가, 약과 동의 체크박스 기능 추가 필요
  // TODO: Firebase Authentication에 비밀번호 조건 강화 규칙 필요
  // 회원가입 메서드
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
