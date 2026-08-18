import 'package:flutter/material.dart';
import '../models/card_model.dart';

enum ContactState {
  none,
  pending,
  connected,
}

class CatalogContactCardWidget extends StatelessWidget {
  final CardModel card;
  final ContactState state;
  final VoidCallback? onPressed;

  const CatalogContactCardWidget({
    super.key,
    required this.card,
    required this.state,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(card.cardColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.18),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardColor.withOpacity(0.35),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 5,
                  color: cardColor,
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 95,
                  height: 82,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: card.photoUrl.isNotEmpty
                            ? Image.network(
                          card.photoUrl,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          color: cardColor,
                          child: Center(
                            child: Text(
                              card.fullName.isNotEmpty
                                  ? card.fullName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            card.position,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: cardColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (card.company.isNotEmpty)
                            Text(
                              card.company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildAction(cardColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(Color color) {
    switch (state) {
      case ContactState.none:
        return InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
        );

      case ContactState.pending:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Icon(
            Icons.schedule,
            color: Colors.grey.shade500,
            size: 20,
          ),
        );

      case ContactState.connected:
        return Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 28,
        );
    }
  }
}