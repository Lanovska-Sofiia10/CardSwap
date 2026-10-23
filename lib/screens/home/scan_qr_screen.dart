import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'home_screen.dart';
import '../../repositories/scan_qr_repository.dart';
import '../../services/notification_service.dart';

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
  bool _isProcessing = false;
  final ScanQrRepository _repository = ScanQrRepository();

  static const double frameSize = 260;
  static const double frameOffsetY = -40;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.addExchangeListener(_onExchangeSuccess);
  }

  void _onExchangeSuccess() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(
          initialIndex: 3,
        ),
      ),
          (_) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleScan(String cardId) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _repository.exchangeCards(
        scannedCardId: cardId,
        myCardId: widget.myCardId,
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll("Exception: ", "");
      _showErrorSnackBar(message);

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Сканування QR',
          style: TextStyle(
            color: Colors.white,
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
              if (_isProcessing) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final cardId = barcodes.first.rawValue;
              if (cardId == null || cardId.isEmpty) return;

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
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
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

  @override
  void dispose() {
    NotificationService.instance.removeExchangeListener(_onExchangeSuccess);
    super.dispose();
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