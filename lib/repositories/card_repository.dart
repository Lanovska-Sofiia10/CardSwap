import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/backend_service.dart';
import '../models/card_model.dart';

class CardRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BackendService.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.error is SocketException) {
      return 'Немає зв’язку з сервером. Перевірте підключення до інтернету.';
    }
    return e.response?.data?['message'] ?? defaultMessage;
  }

  Future<void> createCard(CardModel card, File? image) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Користувач не авторизований");

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
      "cardColor": card.cardColor.toString(),
      "showInCatalog": card.showInCatalog.toString(),
      if (image != null)
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: "photo.jpg",
        ),
    });

    try {
      await _dio.post(
        "/cards",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Помилка створення картки'));
    }
  }

  Future<void> updateCard(String cardId, CardModel card, File? image) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Користувач не авторизований");

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
      "cardColor": card.cardColor.toString(),
      "showInCatalog": card.showInCatalog.toString(),
      if (image != null)
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: "photo.jpg",
        ),
    });

    try {
      await _dio.put(
        "/cards/$cardId",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Помилка оновлення картки'));
    }
  }

  Future<List<CardModel>> getMyCards() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Користувач не авторизований");

    final token = await user.getIdToken();

    try {
      final response = await _dio.get(
        "/cards/my",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final List data = response.data["data"] ?? [];
      return data.map((e) => CardModel.fromJson(e, e["id"] ?? e["_id"] ?? '')).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Помилка завантаження карток'));
    }
  }

  Future<void> deleteCard(String cardId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Користувач не авторизований");

    final token = await user.getIdToken();

    try {
      await _dio.delete(
        "/cards/$cardId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e, 'Помилка видалення картки'));
    }
  }
}