import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class ScanQrScreen extends StatefulWidget {
  final String myCardId;

  const ScanQrScreen({
    super.key,
    required this.myCardId,
  });

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false;

  static const double frameSize = 260;
  static const double frameOffsetY = -40;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Сканування QR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: Rect.fromCenter(
              center: Offset(
                screenSize.width / 2,
                screenSize.height / 2 + frameOffsetY,
              ),
              width: frameSize,
              height: frameSize,
            ),
            onDetect: (capture) {
              if (_isScanned) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final cardId = barcodes.first.rawValue;
              if (cardId == null) return;

              _isScanned = true;

              print("SCANNED ID: $cardId");

              _handleScan(cardId);
            },
          ),

          CustomPaint(
            size: Size.infinite,
            painter: ScannerOverlayPainter(
              frameSize: frameSize,
              offsetY: frameOffsetY,
            ),
          ),

    Positioned(
    top: 30,
    left: 24,
    right: 24,
    child: Column(
    children: const [
    Icon(
    Icons.qr_code_scanner,
    size: 60,
    color: Color(0xFFF59E0B),
    ),
    SizedBox(height: 16),
    Text(
    'Наведіть камеру на QR-код',
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    ],
    ),
    ),

          Center(
            child: Transform.translate(
              offset: const Offset(0, frameOffsetY),
              child: Container(
                width: frameSize,
                height: frameSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33F59E0B),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 32,
            right: 32,
            child: Text(
              'Контакт буде додано автоматично після успішного сканування',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(String cardId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final cardDoc = await FirebaseFirestore.instance
          .collection('cards')
          .doc(cardId)
          .get();

      if (!cardDoc.exists) {
        throw Exception('Візитку не знайдено');
      }

      final scannedCard = cardDoc.data()!;

      final scannedUserId = scannedCard['ownerId'];

      final myCardId = widget.myCardId; // або активна картка

      final contactsRef = FirebaseFirestore.instance.collection('contacts');

      // 🔥 1. запис для мене
      await contactsRef.add({
        'ownerUserId': currentUser.uid,
        'ownerCardId': myCardId,
        'contactUserId': scannedUserId,
        'contactCardId': cardId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // 🔥 2. зворотній запис (щоб у нього теж з'явилось)
      await contactsRef.add({
        'ownerUserId': scannedUserId,
        'ownerCardId': cardId,
        'contactUserId': currentUser.uid,
        'contactCardId': myCardId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(
            initialIndex: 3,
          ),
        ),
            (route) => false,
      );

    } catch (e) {
      print("ERROR: $e");
      _isScanned = false;
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double frameSize;
  final double offsetY;

  ScannerOverlayPainter({
    required this.frameSize,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final screenRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    final holeRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2 + offsetY,
      ),
      width: frameSize,
      height: frameSize,
    );

    final path = Path()
      ..addRect(screenRect)
      ..addRRect(
        RRect.fromRectAndRadius(
          holeRect,
          const Radius.circular(28),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

