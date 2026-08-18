import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'backend_service.dart';

class ApiService {
  static Future<dynamic> get(String endpoint) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken();

    final response = await http.post(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  static Future<dynamic> delete(
      String endpoint,
      Map<String, dynamic> body,
      ) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken();

    final response = await http.delete(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      return jsonDecode(response.body);

    }

    throw Exception(response.body);
  }

  static Future<dynamic> patch(
      String endpoint,
      Map<String, dynamic> body,
      ) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken();

    final response = await http.patch(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {

      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

}