import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Sign Up Failed: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authState => _auth.authStateChanges();
}
