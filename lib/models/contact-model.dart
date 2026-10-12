import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String id;
  final String ownerUserId;
  final String ownerCardId;
  final String contactUserId;
  final String contactCardId;
  final DateTime? createdAt;

  ContactModel({
    required this.id,
    required this.ownerUserId,
    required this.ownerCardId,
    required this.contactUserId,
    required this.contactCardId,
    this.createdAt,
  });

  factory ContactModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    DateTime? parsedDate;
    if (json['createdAt'] is Timestamp) {
      parsedDate = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      parsedDate = DateTime.tryParse(json['createdAt']);
    }

    return ContactModel(
      id: id,
      ownerUserId: json['ownerUserId'] ?? '',
      ownerCardId: json['ownerCardId'] ?? '',
      contactUserId: json['contactUserId'] ?? '',
      contactCardId: json['contactCardId'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'ownerCardId': ownerCardId,
      'contactUserId': contactUserId,
      'contactCardId': contactCardId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}