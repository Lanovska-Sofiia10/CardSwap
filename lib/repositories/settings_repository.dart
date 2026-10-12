import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_service.dart';

class SettingsRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String get email =>
      _auth.currentUser?.email ?? "";

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувача не знайдено");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(
      credential,
    );
  }

  Future<void> deleteAccount() async {
    await ApiService.delete('/users/me', {});
  }

  Future<void> sendResetPasswordEmail() async {
    final email = _auth.currentUser?.email;

    if (email == null) {
      throw Exception("Email не знайдено");
    }

    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }
}