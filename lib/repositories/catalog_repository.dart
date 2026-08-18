import 'package:http/http.dart';

import '../models/catalog_data.dart';
import '../models/catalog_requests_response.dart';
import '../models/contact_request_model.dart';
import '../services/api_service.dart';
import 'dart:async';
import '../models/card_model.dart';
import '../widgets/catalog_contact_card_widget.dart';

class CatalogRepository {

  Future<CatalogData> loadCatalog() async {
    final response = await ApiService.get("/catalog");

    final myCards = (response["myCards"] as List)
        .map(
          (e) => CardModel.fromJson(
        e,
        e["id"],
      ),
    )
        .toList();

    final catalogCards = (response["catalogCards"] as List)
        .map(
          (e) => CardModel.fromJson(
        e,
        e["id"],
      ),
    )
        .toList();

    final Map<String, ContactState> contactStates = {};

    (response["contactStates"] as Map<String, dynamic>).forEach(
          (key, value) {
        switch (value) {
          case "connected":
            contactStates[key] = ContactState.connected;
            break;

          case "pending":
            contactStates[key] = ContactState.pending;
            break;

          default:
            contactStates[key] = ContactState.none;
        }
      },
    );

    return CatalogData(
      myCards: myCards,
      catalogCards: catalogCards,
      contactStates: contactStates,
    );
  }

  Stream<CatalogData> catalogStream() async* {
    while (true) {
      yield await loadCatalog();
      await Future.delayed(const Duration(seconds: 2));
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
      String myCardId,
      String targetCardId,
      ) async {

    await ApiService.delete(
      "/catalog/request",
      {
        "fromCardId": myCardId,
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
    final response =
    await ApiService.get("/catalog/requests");

    return CatalogRequestsResponse
        .fromJson(response)
        .requests;
  }

  Future<void> markRequestsAsRead(
      List<String> requestIds,
      ) async {

    if (requestIds.isEmpty) {
      return;
    }

    await ApiService.patch(
      "/catalog/requests/read",
      {
        "requestIds": requestIds,
      },
    );

  }
}