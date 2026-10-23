import 'package:flutter/material.dart';
import '../models/contact_request_model.dart';

class NotificationRequestCardWidget extends StatelessWidget {
  final ContactRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onOpen;

  const NotificationRequestCardWidget({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final card = request.card;
    final cardColor = Color(card.cardColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onOpen,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 82,
                  color: cardColor,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: card.photoUrl.isNotEmpty
                                ? Image.network(
                              card.photoUrl,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade400,
                                size: 26,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

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
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),

                              if (card.position.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  card.position,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: cardColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              if (card.company.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  card.company,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionButton(
                              icon: Icons.check,
                              onTap: onAccept,
                            ),
                            const SizedBox(width: 7),
                            _ActionButton(
                              icon: Icons.close,
                              onTap: onReject,
                            ),
                          ],
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}