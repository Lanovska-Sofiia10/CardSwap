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
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: cardColor.withOpacity(.8),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      color: cardColor,
                    ),
                  ),

                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 140,
                      height: 90,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(.08),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(80),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                      Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onOpen,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 62,
                                      height: 62,
                                      child: card.photoUrl.isNotEmpty
                                          ? Image.network(
                                        card.photoUrl,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.person),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          card.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          card.position,
                                          style: TextStyle(
                                            color: cardColor,
                                            fontSize: 16,
                                          ),
                                        ),

                                        if (card.company.isNotEmpty) ...[
                                          const SizedBox(height: 2),

                                          Text(
                                            card.company,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                children: [

                  InkWell(
                    onTap: onAccept,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF374151),
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: onReject,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF374151),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
                      ],
                    ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}