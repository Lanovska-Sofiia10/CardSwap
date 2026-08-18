import 'card_model.dart';
import '../widgets/catalog_contact_card_widget.dart';

class CatalogData {
  final List<CardModel> myCards;
  final List<CardModel> catalogCards;
  final Map<String, ContactState> contactStates;

  CatalogData({
    required this.myCards,
    required this.catalogCards,
    required this.contactStates,
  });
}