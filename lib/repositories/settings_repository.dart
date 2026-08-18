import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  String get email =>
      _auth.currentUser?.email ?? "";

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувача не знайдено");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(
      credential,
    );
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final uid = user.uid;

    await _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: uid)
        .get()
        .then((snapshot) async {
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });

    await _firestore
        .collection('notifications')
        .where('senderId', isEqualTo: uid)
        .get()
        .then((snapshot) async {
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });

    // ---------- Видаляємо всі візитки ----------

    final cards = await _firestore
        .collection('cards')
        .where('ownerId', isEqualTo: uid)
        .get();

    for (final card in cards.docs) {
      final data = card.data();

      final photoUrl = data['photoUrl'] ?? '';

      if (photoUrl.toString().isNotEmpty) {
        try {
          await _storage.refFromURL(photoUrl).delete();
        } catch (_) {}
      }

      await card.reference.delete();
    }

    // ---------- Видаляємо контакти користувача ----------

    final ownerContacts = await _firestore
        .collection('contacts')
        .where('ownerUserId', isEqualTo: uid)
        .get();

    for (final contact in ownerContacts.docs) {
      await contact.reference.delete();
    }

    // ---------- Видаляємо користувача з контактів інших ----------

    final incomingContacts = await _firestore
        .collection('contacts')
        .where('contactUserId', isEqualTo: uid)
        .get();

    for (final contact in incomingContacts.docs) {
      await contact.reference.delete();
    }

    // ---------- Видаляємо документ користувача ----------

    await _firestore
        .collection('users')
        .doc(uid)
        .delete();

    // ---------- Видаляємо акаунт Firebase ----------

    await user.delete();
  }

  Future<void> sendResetPasswordEmail() async {
    final email = _auth.currentUser?.email;

    if (email == null) {
      throw Exception("Email не знайдено");
    }

    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }
}