import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../widgets/catalog_card_widget.dart';
import 'home_screen.dart';
import 'scan_qr_screen.dart';
import 'dart:async';
import '../../repositories/card_repository.dart';
import '../../widgets/qr_dialog.dart';
import '../../widgets/card_picker_bottom_sheet.dart';
import '../../repositories/exchange_api_repository.dart';
import '../../services/notification_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() =>
      _ExchangeScreenState();
}

class _ExchangeScreenState
    extends State<ExchangeScreen> {

  bool isLoading = true;

  List<CardModel> cards = [];

  CardModel? selectedCard;

  bool _isQrDialogOpen = false;

  bool _sending = false;

  final CardRepository _repository =
  CardRepository();


  final ExchangeApiRepository _exchangeApiRepository =
  ExchangeApiRepository();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  DateTime _lastShakeTime =
  DateTime.fromMillisecondsSinceEpoch(0);


  @override
  void initState() {
    super.initState();

    loadCards();
    _startAccelerometerListener();
  }

  Future<void> loadCards() async {
    cards = await _repository.getMyCards();

    if (cards.isNotEmpty) {
      selectedCard = cards.first;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  void _startAccelerometerListener() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((event) {

          final now = DateTime.now();

          // Захист від багаторазового спрацювання
          if (now.difference(_lastShakeTime).inSeconds < 2) {
            return;
          }

          const double threshold = 18;

          if (event.x.abs() > threshold) {
            _lastShakeTime = now;

            _startExchange();
          }
        });
  }

  void _onExchangeSuccess() {

    if (!mounted) return;

    if (_isQrDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isQrDialogOpen = false;
    }

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

  Future<void> _showQrDialog(CardModel card) async {

    _isQrDialogOpen = true;

    NotificationService.instance.addExchangeListener(
      _onExchangeSuccess,
    );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => QrDialog(
        card: card,
      ),
    );

    NotificationService.instance.removeExchangeListener(
      _onExchangeSuccess,
    );

    _isQrDialogOpen = false;
  }

  Future<void> _startExchange() async {
    if (selectedCard == null || _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await _exchangeApiRepository.sendExchange(
        cardId: selectedCard!.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Запит на обмін відправлено"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _showCardPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => CardPickerBottomSheet(
        cards: cards,
        selectedCard: selectedCard,
        onSelected: (card) {
          setState(() {
            selectedCard = card;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Обмін',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code,
                      color: Color(0xFFF59E0B),
                    ),
                    onPressed: () {
                      if (selectedCard != null) {
                        _showQrDialog(selectedCard!);
                      }
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Color(0xFFF59E0B),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanQrScreen(
                            myCardId: selectedCard!.id,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 50),

          // Icon
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33F59E0B),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Center(
            child: Text(
              'Готовий до обміну',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Потрясіть телефон або свайпніть,\nщоб обмінятись',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Center(
            child: SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _startExchange,
                icon: const Icon(Icons.bolt),
                label: const Text('Почати обмін'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // My Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Моя візитка',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

        if (cards.length > 1)
    TextButton(
      onPressed: _showCardPicker,
      child: const Text(
        'Обрати',
        style: TextStyle(
          color: Color(0xFFF59E0B),
        ),
      ),
    ),
            ],
          ),

          const SizedBox(height: 12),
        if (selectedCard != null)
            CatalogCardWidget(
              card: selectedCard!,
        ),
        ],
      ),
    );
  }
}