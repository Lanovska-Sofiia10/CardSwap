import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_request_model.dart';
import 'catalog_repository.dart';

class NotificationRepository {
  final CatalogRepository _catalogRepository =
  CatalogRepository();

  String? get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid;

  Future<List<ContactRequestModel>> getRequests() {
    return _catalogRepository.getRequests();
  }

  Future<void> acceptRequest(
      ContactRequestModel request,
      ) async {
    await _catalogRepository.acceptRequest(
      request.id,
    );
  }

  Future<void> rejectRequest(
      ContactRequestModel request,
      ) async {
    await _catalogRepository.rejectRequest(
      request.id,
    );
  }

  Future<void> markAllAsRead(
      List<String> requestIds,
      ) async {

    if (requestIds.isEmpty) return;

    await _catalogRepository.markRequestsAsRead(
      requestIds,
    );

  }
}