import '../models/auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final AuthModel _authModel = AuthModel();

  Future<User?> signUp(String email, String password) async {
    return await _authModel.signUp(email, password);
  }

  Future<User?> signIn(String email, String password) async {
    return await _authModel.signIn(email, password);
  }

  Future<void> signOut() async {
    await _authModel.signOut();
  }

  Stream<User?> get authState => _authModel.authState;
}
