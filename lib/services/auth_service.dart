import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'backend_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${BackendService.baseUrl}/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      final message =
      data['errors'] != null
          ? data['errors'][0]['msg']
          : data['message'] ?? 'Помилка реєстрації';

      throw Exception(message);
    }

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}