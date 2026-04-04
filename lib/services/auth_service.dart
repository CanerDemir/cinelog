import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication wrapper. Watchlist data is stored under each user's UID.
class AuthService {
  AuthService._();

  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  static Future<UserCredential> signInAnonymously() =>
      _auth.signInAnonymously();

  static Future<void> signOut() => _auth.signOut();
}
