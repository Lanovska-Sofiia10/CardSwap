import 'contact_request_model.dart';

class CatalogRequestsResponse {
  final List<ContactRequestModel> requests;

  CatalogRequestsResponse({
    required this.requests,
  });

  factory CatalogRequestsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CatalogRequestsResponse(
      requests: (json["requests"] as List)
          .map(
            (e) => ContactRequestModel.fromJson(
          e,
          e["requestId"],
        ),
      )
          .toList(),
    );
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }

    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'] ?? value['seconds'];
      final nanoseconds =
          value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;

      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds.toInt() * 1000 +
              (nanoseconds is num
                  ? nanoseconds.toInt() ~/ 1000000
                  : 0),
        );
      }
    }

    return DateTime.now();
  }
}