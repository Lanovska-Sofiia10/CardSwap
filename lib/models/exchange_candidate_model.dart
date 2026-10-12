import 'card_model.dart';

class ExchangeCandidateModel {
  final String userId;
  final String cardId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double distance;
  final CardModel? card;

  ExchangeCandidateModel({
    required this.userId,
    required this.cardId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.distance,
    this.card,
  });

  factory ExchangeCandidateModel.fromJson(Map<String, dynamic> json) {
    final request = (json['request'] as Map<String, dynamic>?) ?? {};

    // Шукаємо JSON візитки в json['card'] або в json['request']['card']
    final cardJson = (json['card'] as Map<String, dynamic>?) ??
        (request['card'] as Map<String, dynamic>?);

    final cardIdValue = request['cardId'] as String? ?? json['cardId'] as String? ?? '';

    return ExchangeCandidateModel(
      userId: request['userId'] as String? ?? json['userId'] as String? ?? '',
      cardId: cardIdValue,
      latitude: (request['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (request['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (request['accuracy'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      card: (cardJson != null)
          ? CardModel.fromJson(cardJson, cardIdValue)
          : null,
    );
  }
}