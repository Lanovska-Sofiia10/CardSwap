import 'package:flutter/material.dart';

import '../models/card_model.dart';
import 'catalog_card_widget.dart';

class CardPickerBottomSheet extends StatelessWidget {
  final List<CardModel> cards;
  final CardModel? selectedCard;
  final ValueChanged<CardModel> onSelected;

  const CardPickerBottomSheet({
    super.key,
    required this.cards,
    required this.selectedCard,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: cards.length > 3 ? 500 : null,
          child: ListView(
            shrinkWrap: true,
            children: [

              const Text(
                'Оберіть візитку',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...cards.map((card) {
                return GestureDetector(
                  onTap: () {
                    onSelected(card);
                    Navigator.pop(context);
                  },
                  child: Stack(
                    children: [

                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 12),
                        child: CatalogCardWidget(
                          card: card,
                        ),
                      ),

                      if (selectedCard?.id == card.id)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}