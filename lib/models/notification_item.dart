import 'card_model.dart';
import 'contact_request_model.dart';

class NotificationItem {
  final ContactRequestModel request;
  final CardModel card;

  NotificationItem({
    required this.request,
    required this.card,
  });
}