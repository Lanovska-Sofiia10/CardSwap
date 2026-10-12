import 'package:cloud_firestore/cloud_firestore.dart';
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
    BaseOptions(
      baseUrl: BackendService.baseUrl,
    ),
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ContactItem>> contactsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('contacts')
        .where('ownerUserId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap(_mapContactsToItems);
  }

  Future<List<ContactItem>> _mapContactsToItems(
      QuerySnapshot snapshot,
      ) async {
    if (snapshot.docs.isEmpty) {
      return [];
    }

    // Карта: contactCardId -> документ контакту з Firestore
    final Map<String, QueryDocumentSnapshot> contactDocs = {};

    for (var doc in snapshot.docs) {
      final cardId = doc['contactCardId'] as String?;
      if (cardId != null && cardId.isNotEmpty) {
        contactDocs[cardId] = doc;
      }
    }

    final ids = contactDocs.keys.toList();
    if (ids.isEmpty) return [];

    List<ContactItem> items = [];

    // Чанкування по 10 елементів
    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.skip(i).take(10).toList();

      final cardsSnapshot = await _firestore
          .collection('cards')
          .where(
        FieldPath.documentId,
        whereIn: chunk,
      )
          .get();

      for (var doc in cardsSnapshot.docs) {
        final card = CardModel.fromJson(doc.data(), doc.id);
        final contactDoc = contactDocs[card.id];

        if (contactDoc != null) {
          final data = contactDoc.data() as Map<String, dynamic>;
          items.add(
            ContactItem(
              contactDocId: contactDoc.id,
              ownerCardId: data['ownerCardId'] ?? '',
              contactCardId: card.id,
              card: card,
            ),
          );
        }
      }
    }

    return items;
  }

  /// Видалення контакту через API
  Future<void> deleteContact(String contactCardId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token = await user.getIdToken();

    try {
      await _dio.delete(
        "/contacts/$contactCardId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Помилка видалення контакту";
      throw Exception(message);
    }
  }
}