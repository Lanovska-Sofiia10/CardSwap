import 'dart:io';

import '../models/user_profile_model.dart';
import '../services/api_service.dart';

class ProfileRepository {
  Future<UserProfileModel?> loadProfile() async {
    final response = await ApiService.get("/profile");

    if (response == null || response["data"] == null) {
      return null;
    }

    final data = Map<String, dynamic>.from(response["data"]);
    final String id = data["id"] ?? data["_id"] ?? "";

    return UserProfileModel.fromMap(id, data);
  }

  Future<UserProfileModel> updateProfile({
    required String displayName,
    required String fullName,
    required String phone,
    required String position,
    File? photo,
  }) async {
    final response = await ApiService.putMultipart(
      "/profile",
      fields: {
        "displayName": displayName,
        "fullName": fullName,
        "phone": phone,
        "position": position,
      },
      file: photo,
      fileField: "photo",
    );

    if (response == null) {
      throw Exception("Не вдалося отримати відповідь від сервера");
    }

    if (response["success"] == false) {
      throw Exception(response["message"] ?? "Помилка оновлення профілю");
    }

    final Map<String, dynamic> data = (response.containsKey("data") && response["data"] != null)
        ? Map<String, dynamic>.from(response["data"])
        : Map<String, dynamic>.from(response);

    final String id = data["id"] ?? data["_id"] ?? "";

    return UserProfileModel.fromMap(id, data);
  }
}