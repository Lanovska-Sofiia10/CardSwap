import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_profile_model.dart';

class ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  Future<UserProfileModel?> loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) return null;

    final data = userDoc.data();

    if (data == null) return null;

    return UserProfileModel(
      id: user.uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      position: data['position'] ?? '',
    );
  }

  Future<String?> uploadPhoto({
    required File? image,
  }) async {
    final user = _auth.currentUser;

    if (user == null || image == null) {
      return null;
    }

    final ref = _storage
        .ref()
        .child('profile_photos/${user.uid}.jpg');

    final snapshot = await ref.putFile(image);

    if (snapshot.state != TaskState.success) {
      return null;
    }

    return await ref.getDownloadURL();
  }

  Future<void> updateProfile({
    required String displayName,
    required String fullName,
    required String phone,
    required String position,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'displayName': displayName,
      'fullName': fullName,
      'phone': phone,
      'position': position,

      if (photoUrl != null)
        'photoUrl': photoUrl,
    });
  }
}