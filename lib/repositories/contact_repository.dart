import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';
import '../services/backend_service.dart';

class ContactRepository {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BackendService.baseUrl,
    ),
  );

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<CardModel>> contactsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final contactsStream = _firestore
        .collection('contacts')
        .where(
      'ownerUserId',
      isEqualTo: user.uid,
    )
        .snapshots();

    final cardsStream = _firestore
        .collection('cards')
        .snapshots();

    return Rx.combineLatest2(
      contactsStream,
      cardsStream,
          (QuerySnapshot contacts, QuerySnapshot _) => contacts,
    ).asyncMap(_mapContactsToCards);
  }

  Future<List<CardModel>> _mapContactsToCards(
      QuerySnapshot snapshot) async {
    if (snapshot.docs.isEmpty) {
      return [];
    }

    final ids = snapshot.docs
        .map((e) => e['contactCardId'] as String)
        .toList();

    List<CardModel> cards = [];

    for (int i = 0; i < ids.length; i += 10) {
      final chunk = ids.skip(i).take(10).toList();

      final cardsSnapshot = await _firestore
          .collection('cards')
          .where(
        FieldPath.documentId,
        whereIn: chunk,
      )
          .get();

      cards.addAll(
        cardsSnapshot.docs.map(
              (e) => CardModel.fromJson(
            e.data(),
            e.id,
          ),
        ),
      );
    }

    return cards;
  }

  Future<void> deleteContact(
      String contactCardId,
      ) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token =
    await user.getIdToken();

    await _dio.delete(
      "/contacts/$contactCardId",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

  }

}