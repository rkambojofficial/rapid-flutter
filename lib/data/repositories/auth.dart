import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  static final auth = FirebaseAuth.instance;

  static User get currentUser => auth.currentUser;

  static Stream<User> get authState => auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String password) {
    return auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUp(String email, String password) {
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() {
    return auth.signOut();
  }
}
