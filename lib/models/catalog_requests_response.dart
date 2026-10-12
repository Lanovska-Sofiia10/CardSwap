import 'contact_request_model.dart';

class CatalogRequestsResponse {
  final List<ContactRequestModel> requests;

  CatalogRequestsResponse({
    required this.requests,
  });

  factory CatalogRequestsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawRequests = json["requests"] as List? ?? [];

    return CatalogRequestsResponse(
      requests: rawRequests
          .map(
            (e) => ContactRequestModel.fromJson(
          e as Map<String, dynamic>,
          e["requestId"] ?? "",
        ),
      )
          .toList(),
    );
  }

  /// Універсальний парсер Timestamp для використанная в ContactRequestModel
  static DateTime parseCreatedAt(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'] ?? value['seconds'];
      final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;

      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds.toInt() * 1000 +
              (nanoseconds is num ? nanoseconds.toInt() ~/ 1000000 : 0),
        );
      }
    }

    return DateTime.now();
  }
}