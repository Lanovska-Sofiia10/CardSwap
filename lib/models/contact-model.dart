class ContactModel {
  final String id;

  final String ownerUserId;
  final String ownerCardId;

  final String contactUserId;
  final String contactCardId;

  final DateTime createdAt;

  ContactModel({
    required this.id,
    required this.ownerUserId,
    required this.ownerCardId,
    required this.contactUserId,
    required this.contactCardId,
    required this.createdAt,
  });

  factory ContactModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    return ContactModel(
      id: id,
      ownerUserId: json['ownerUserId'] ?? '',
      ownerCardId: json['ownerCardId'] ?? '',
      contactUserId: json['contactUserId'] ?? '',
      contactCardId: json['contactCardId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'ownerCardId': ownerCardId,
      'contactUserId': contactUserId,
      'contactCardId': contactCardId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}