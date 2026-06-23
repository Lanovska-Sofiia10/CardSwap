import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/card_model.dart';

class CardViewWidget extends StatelessWidget {
  final CardModel card;

  const CardViewWidget({
    super.key,
    required this.card,
  });

  Future<void> _openPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    await launchUrl(uri);
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    String finalUrl = url;

    if (!url.startsWith('http')) {
      finalUrl = 'https://$url';
    }

    await launchUrl(
      Uri.parse(finalUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(card.cardColor);

    final contacts = <Widget>[
      if (card.email.isNotEmpty)
        SocialButton(
          icon: Icons.email_outlined,
          color: cardColor,
          onTap: () => _openEmail(card.email),
        ),

      if (card.phone.isNotEmpty)
        SocialButton(
          icon: Icons.phone_outlined,
          color: cardColor,
          onTap: () => _openPhone(card.phone),
        ),

      if (card.linkedin.isNotEmpty)
        SocialButton(
          icon: Icons.business_center_outlined,
          color: cardColor,
          onTap: () => _openUrl(card.linkedin),
        ),

      if (card.telegram.isNotEmpty)
        SocialButton(
          icon: Icons.send,
          color: cardColor,
          onTap: () => _openUrl(card.telegram),
        ),

      if (card.instagram.isNotEmpty)
        SocialButton(
          icon: Icons.camera_alt_outlined,
          color: cardColor,
          onTap: () => _openUrl(card.instagram),
        ),

      if (card.github.isNotEmpty)
        SocialButton(
          icon: Icons.code,
          color: cardColor,
          onTap: () => _openUrl(card.github),
        ),
    ];

    return Container(
        margin: const EdgeInsets.all(8),
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
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),

              // якщо потрібна рамка
              border: Border.all(
                color: cardColor.withOpacity(0.8),
                width: 1.2,
              ),
            ),
            child: Stack(
          children: [
            // Верхня кольорова смуга
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                color: cardColor,
              ),
            ),

            // Декоративний елемент справа
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 140,
                height: 90,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 62,
                          height: 62,
                          child: card.photoUrl.isNotEmpty
                              ? Image.network(card.photoUrl, fit: BoxFit.cover)
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
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.position,
                              style: TextStyle(
                                fontSize: 16,
                                color: cardColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(children: contacts),
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

class SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

}

