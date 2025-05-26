import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Вход через Google
  Future<User?> signInWithGoogle() async {
    try {
      // Запускаем окно выбора аккаунта
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // если пользователь отменил вход

      // Получаем токены
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Создаём Firebase-учётку
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Входим в Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Ошибка входа через Google: $e");
      return null;
    }
  }

  /// Выход из Google и Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
