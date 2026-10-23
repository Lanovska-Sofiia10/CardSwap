import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../models/card_model.dart';
import '../services/backend_service.dart';

class ContactItem {
  final String contactDocId;
  final String ownerCardId;
  final String contactCardId;
  final CardModel card;

  ContactItem({
    required this.contactDocId,
    required this.ownerCardId,
    required this.contactCardId,
    required this.card,
  });
}

class ContactRepository {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: BackendService.baseUrl),
  );

  Future<List<ContactItem>> getContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken();

    try {
      final response = await _dio.get(
        "/contacts",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final List data = response.data['data'] ?? [];

      return data.map((item) {
        final cardData = item['card'] as Map<String, dynamic>;
        final card = CardModel.fromJson(
          cardData,
          cardData['id'] ?? cardData['_id'] ?? '',
        );

        return ContactItem(
          contactDocId: item['id'] ?? '',
          ownerCardId: item['ownerCardId'] ?? '',
          contactCardId: item['contactCardId'] ?? '',
          card: card,
        );
      }).toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Помилка завантаження контактів";
      throw Exception(message);
    }
  }

  Stream<List<ContactItem>> contactsStream() async* {
    while (true) {
      try {
        final contacts = await getContacts();
        yield contacts;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> deleteContact(String contactCardId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Користувач не авторизований");

    final token = await user.getIdToken();

    try {
      await _dio.delete(
        "/contacts/$contactCardId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Помилка видалення контакту";
      throw Exception(message);
    }
  }
}