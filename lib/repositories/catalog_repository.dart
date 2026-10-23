import 'dart:async';
import '../models/card_model.dart';
import '../models/catalog_data.dart';
import '../models/catalog_requests_response.dart';
import '../models/contact_request_model.dart';
import '../services/api_service.dart';
import '../widgets/catalog_contact_card_widget.dart';

class CatalogRepository {

  Future<CatalogData> loadCatalog() async {
    final response = await ApiService.get("/catalog");

    if (response == null || response is! Map<String, dynamic>) {
      return CatalogData(
        myCards: [],
        catalogCards: [],
        contactStates: {},
      );
    }

    final myCardsList = response["myCards"] as List? ?? [];
    final myCards = myCardsList
        .map((e) => CardModel.fromJson(e, e["id"] ?? ""))
        .toList();

    final catalogCardsList = response["catalogCards"] as List? ?? [];
    final catalogCards = catalogCardsList
        .map((e) => CardModel.fromJson(e, e["id"] ?? ""))
        .toList();

    final Map<String, ContactState> contactStates = {};

    final rawStates = response["contactStates"] as Map<String, dynamic>? ?? {};
    rawStates.forEach((key, value) {
      switch (value) {
        case "connected":
          contactStates[key] = ContactState.connected;
          break;
        case "pendingOutgoing":
          contactStates[key] = ContactState.pendingOutgoing;
          break;
        case "pendingIncoming":
          contactStates[key] = ContactState.pendingIncoming;
          break;
        default:
          contactStates[key] = ContactState.none;
      }
    });

    return CatalogData(
      myCards: myCards,
      catalogCards: catalogCards,
      contactStates: contactStates,
    );
  }

  Stream<CatalogData> catalogStream() async* {
    while (true) {
      try {
        yield await loadCatalog();
      } catch (e) {
        print("Error in catalogStream: $e");
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> sendRequest(
      String fromCardId,
      String toCardId,
      ) async {
    await ApiService.post(
      "/catalog/request",
      {
        "fromCardId": fromCardId,
        "toCardId": toCardId,
      },
    );
  }

  Future<void> cancelRequest(
      String targetCardId,
      ) async {
    await ApiService.delete(
      "/catalog/request",
      {
        "toCardId": targetCardId,
      },
    );
  }

  Future<void> acceptRequest(
      String requestId,
      ) async {
    await ApiService.post(
      "/catalog/request/accept",
      {
        "requestId": requestId,
      },
    );
  }

  Future<void> rejectRequest(
      String requestId,
      ) async {
    await ApiService.post(
      "/catalog/request/reject",
      {
        "requestId": requestId,
      },
    );
  }

  Future<List<ContactRequestModel>> getRequests() async {
    final response = await ApiService.get("/catalog/requests");

    if (response == null) return [];

    return CatalogRequestsResponse.fromJson(response).requests;
  }

  Future<void> markRequestsAsRead(
      List<String> requestIds,
      ) async {
    if (requestIds.isEmpty) return;

    await ApiService.patch(
      "/catalog/requests/read",
      {
        "requestIds": requestIds,
      },
    );
  }
}