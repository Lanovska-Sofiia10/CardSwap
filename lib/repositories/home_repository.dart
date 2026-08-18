import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class HomeRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> logout() async {
    await NotificationService.instance.deleteCurrentToken();
    await _auth.signOut();
  }

  Stream<bool> hasUnreadRequests() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('contact_requests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty,
    );
  }
}