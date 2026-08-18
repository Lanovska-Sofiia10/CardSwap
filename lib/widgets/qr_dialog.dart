import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/card_model.dart';

class QrDialog extends StatelessWidget {
  final CardModel card;

  const QrDialog({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AF59E0B),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.qr_code_2,
                color: Colors.white,
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Покажіть QR-код',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Інша людина може відсканувати код та миттєво отримати вашу візитку',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: card.id,
                size: 220,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.flash_on,
                    color: Color(0xFFF59E0B),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Контакт буде додано автоматично після сканування',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}