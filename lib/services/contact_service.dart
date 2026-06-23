import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/contact-model.dart';

class ContactService {
  final _contacts =
  FirebaseFirestore.instance.collection('contacts');

  Future<void> createContact({
    required ContactModel contact,
  }) async {
    await _contacts.add(
      contact.toJson(),
    );
  }

  Future<List<ContactModel>> getContacts(
      String userId,
      ) async {
    final snapshot = await _contacts
        .where(
      'ownerUserId',
      isEqualTo: userId,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => ContactModel.fromJson(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }
}