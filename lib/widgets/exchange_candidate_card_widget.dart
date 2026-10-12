import 'package:flutter/material.dart';
import '../models/card_model.dart';

class ExchangeCandidateCardWidget extends StatelessWidget {
  final CardModel? card;
  final double distance;
  final VoidCallback onTap;

  const ExchangeCandidateCardWidget({
    super.key,
    required this.card,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Якщо card ще null (наприклад, бекенд не повернув), беремо значення за замовчуванням
    final cardColor = Color(card?.cardColor ?? 0xFF4A90E2);
    final fullName = (card != null && card!.fullName.trim().isNotEmpty)
        ? card!.fullName
        : 'Користувач поруч';
    final position = card?.position ?? '';
    final company = card?.company ?? '';
    final photoUrl = card?.photoUrl ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Ліва кольорова полоса як у каталозі
                  Container(
                    width: 6,
                    color: cardColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Аватар або ініціали
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: cardColor.withOpacity(0.15),
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: cardColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),

                          // Інформація про користувача
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (position.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    position,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                                if (company.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    company,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Бейдж з відстанню
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me,
                                  size: 14,
                                  color: cardColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${distance.toStringAsFixed(1)} м',
                                  style: TextStyle(
                                    color: cardColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}