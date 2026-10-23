import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/exchange_candidate_model.dart';
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

    final position = LocationService.getBestAvailablePosition();

    if (position == null) {
      throw Exception(
        "Current location is not available yet.",
      );
    }

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
        "accuracy": position.accuracy,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<bool> selectCandidate({
    required String targetUserId,
    required String cardId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse("${BackendService.baseUrl}/exchange/select"),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "targetUserId": targetUserId,
        "cardId": cardId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['matched'] as bool? ?? false;
  }

  Future<List<ExchangeCandidateModel>> getCandidates() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated.");
    }

    final position = LocationService.getBestAvailablePosition();

    if (position == null) {
      throw Exception(
        "Current location is not available yet.",
      );
    }

    final idToken = await user.getIdToken();

    final uri = Uri.parse(
      "${BackendService.baseUrl}/exchange/candidates",
    ).replace(
      queryParameters: {
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $idToken",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidatesJson = data['candidates'] as List<dynamic>? ?? [];

    return candidatesJson
        .map(
          (item) => ExchangeCandidateModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}