import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../services/backend_service.dart';
import '../services/location_service.dart';

class ExchangeApiRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendExchange({
    required String cardId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated.");
    }

    final position =
    await LocationService.getCurrentPosition();

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse("${BackendService.baseUrl}/exchange"),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cardId": cardId,
        "latitude": position.latitude,
        "longitude": position.longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}