import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/backend_service.dart';
import '../models/card_model.dart';

class CardRepository {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BackendService.baseUrl,
    ),
  );

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> createCard(
      CardModel card,
      File? image,
      ) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token =
    await user.getIdToken();

    final formData = FormData.fromMap({

      "fullName": card.fullName,
      "position": card.position,
      "company": card.company,

      "phone": card.phone,
      "email": card.email,
      "website": card.website,

      "linkedin": card.linkedin,
      "telegram": card.telegram,
      "instagram": card.instagram,
      "github": card.github,

      "about": card.about,

      "cardColor": card.cardColor,

      "showInCatalog": card.showInCatalog,

      if (image != null)
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: "photo.jpg",
        ),
    });

    try {

      final response = await _dio.post(
        "/cards",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<void> updateCard(
      String cardId,
      CardModel card,
      File? image,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token = await user.getIdToken();

    final formData = FormData.fromMap({
      "fullName": card.fullName,
      "position": card.position,
      "company": card.company,

      "phone": card.phone,
      "email": card.email,
      "website": card.website,

      "linkedin": card.linkedin,
      "telegram": card.telegram,
      "instagram": card.instagram,
      "github": card.github,

      "about": card.about,

      "cardColor": card.cardColor,
      "showInCatalog": card.showInCatalog,

      if (image != null)
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: "photo.jpg",
        ),
    });

    try {

      final response = await _dio.put(
        "/cards/$cardId",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<List<CardModel>> getMyCards() async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token = await user.getIdToken();

    final response = await _dio.get(
      "/cards/my",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    final List data = response.data["data"];

    return data
        .map((e) => CardModel.fromJson(e, e["id"]))
        .toList();
  }

  Future<void> deleteCard(String cardId) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token = await user.getIdToken();

    await _dio.delete(
      "/cards/$cardId",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
  }

}