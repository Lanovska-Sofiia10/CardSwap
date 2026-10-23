import '../models/subscription_model.dart';
import '../services/api_service.dart';

class SubscriptionRepository {
  Future<Map<String, dynamic>> getMySubscription() async {
    final response = await ApiService.get('/subscription/me');

    if (response is Map<String, dynamic> && response['data'] != null) {
      return Map<String, dynamic>.from(response['data']);
    }

    return Map<String, dynamic>.from(response);
  }

  Future<SubscriptionModel> getSubscriptionModel() async {
    final response = await getMySubscription();

    return SubscriptionModel.fromJson(response);
  }

  Future<List<int>> getAllowedColors() async {
    final subscription = await getMySubscription();

    final limits = Map<String, dynamic>.from(
      subscription['limits'] ?? {},
    );

    final colors = limits['allowedColors'];

    if (colors is! List) {
      return [];
    }

    return colors
        .map((color) => (color as num).toInt())
        .toList();
  }
}