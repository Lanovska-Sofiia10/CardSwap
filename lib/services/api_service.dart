import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'backend_service.dart';

class ApiService {

  static dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    try {
      final errorData = jsonDecode(response.body);
      final message = errorData['errors'] != null
          ? errorData['errors'][0]['msg']
          : errorData['message'] ?? response.body;
      throw Exception(message);
    } catch (_) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Server error (${response.statusCode})');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    return _parseResponse(response);
  }

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final response = await http.post(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _parseResponse(response);
  }

  static Future<dynamic> delete(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final response = await http.delete(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _parseResponse(response);
  }

  static Future<dynamic> patch(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final response = await http.patch(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _parseResponse(response);
  }

  static Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final response = await http.put(
      Uri.parse("${BackendService.baseUrl}$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _parseResponse(response);
  }

  static Future<dynamic> putMultipart(
      String endpoint, {
        required Map<String, String> fields,
        File? file,
        String fileField = "photo",
      }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final token = await user.getIdToken();
    final request = http.MultipartRequest(
      "PUT",
      Uri.parse("${BackendService.baseUrl}$endpoint"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token",
    });

    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _parseResponse(response);
  }
}