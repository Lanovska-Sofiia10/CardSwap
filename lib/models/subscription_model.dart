class SubscriptionModel {
  final String plan;
  final String status;
  final int? contactsPerMonth;
  final int cards;
  final int contactsCreated;
  final int? remainingContacts;

  const SubscriptionModel({
    required this.plan,
    required this.status,
    required this.contactsPerMonth,
    required this.cards,
    required this.contactsCreated,
    required this.remainingContacts,
  });

  bool get hasReachedContactLimit {
    return remainingContacts != null && remainingContacts! <= 0;
  }

  bool get isUnlimitedContacts {
    return contactsPerMonth == null;
  }

  factory SubscriptionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final subscription = Map<String, dynamic>.from(
      json['subscription'] ?? {},
    );

    final limits = Map<String, dynamic>.from(
      json['limits'] ?? {},
    );

    final usage = Map<String, dynamic>.from(
      json['usage'] ?? {},
    );

    final remaining = Map<String, dynamic>.from(
      json['remaining'] ?? {},
    );

    return SubscriptionModel(
      plan: subscription['plan'] as String? ?? 'free',
      status: subscription['status'] as String? ?? 'active',
      contactsPerMonth: (limits['contactsPerMonth'] as num?)?.toInt(),
      cards: (limits['cards'] as num?)?.toInt() ?? 0,
      contactsCreated: (usage['contactsCreated'] as num?)?.toInt() ?? 0,
      remainingContacts: (remaining['contacts'] as num?)?.toInt(),
    );
  }
}