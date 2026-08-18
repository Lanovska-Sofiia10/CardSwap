import 'card_model.dart';

class ContactRequestModel {
  final String id;

  final String fromUserId;
  final String fromCardId;

  final String toUserId;
  final String toCardId;

  final String status;

  final bool isRead;

  final DateTime createdAt;

  final CardModel card;

  ContactRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromCardId,
    required this.toUserId,
    required this.toCardId,
    required this.status,
    required this.isRead,
    required this.createdAt,
    required this.card,
  });

  factory ContactRequestModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    return ContactRequestModel(
      id: id,

      fromUserId: json['fromUserId'] ?? '',
      fromCardId: json['fromCardId'] ?? '',

      toUserId: json['toUserId'] ?? '',
      toCardId: json['toCardId'] ?? '',

      status: json['status'] ?? 'pending',

      isRead: json['isRead'] ?? false,

      createdAt: _parseCreatedAt(json['createdAt']),

      card: CardModel.fromJson(
        json["card"] as Map<String, dynamic>,
        json["card"]["id"] as String,
      ),
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

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'fromCardId': fromCardId,
      'toUserId': toUserId,
      'toCardId': toCardId,
      'status': status,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}