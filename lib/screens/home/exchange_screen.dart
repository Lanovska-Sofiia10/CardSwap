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
import '../../models/subscription_model.dart';
import '../../repositories/subscription_repository.dart';
import '../../models/exchange_candidate_model.dart';
import '../../widgets/exchange_candidate_bottom_sheet.dart';
import 'create_card_screen.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  bool isLoading = true;
  List<CardModel> cards = [];
  CardModel? selectedCard;
  bool _isQrDialogOpen = false;
  bool _sending = false;

  final CardRepository _repository = CardRepository();
  final ExchangeApiRepository _exchangeApiRepository = ExchangeApiRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();

  SubscriptionModel? _subscription;
  List<ExchangeCandidateModel> _candidates = [];
  bool _loadingCandidates = false;
  Timer? _candidatePollingTimer;

  bool get _canExchange {
    if (_subscription == null) {
      return false;
    }
    return _subscription!.remainingContacts == null ||
        _subscription!.remainingContacts! > 0;
  }

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    loadCards();
    _loadSubscription();
    _startAccelerometerListener();
  }

  // Завантаження карток користувача
  Future<void> loadCards({bool showLoading = true}) async {
    if (showLoading && cards.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final myCards = await _repository.getMyCards();

      if (!mounted) return;

      setState(() {
        cards = myCards;

        // Перевіряємо та вибираємо візитку
        if (cards.isNotEmpty) {
          if (selectedCard == null || !cards.any((c) => c.id == selectedCard!.id)) {
            selectedCard = cards.first;
          } else {
            selectedCard = cards.firstWhere((c) => c.id == selectedCard!.id);
          }
        } else {
          selectedCard = null;
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _candidatesAreEqual(
      List<ExchangeCandidateModel> first,
      List<ExchangeCandidateModel> second,
      ) {
    if (first.length != second.length) return false;

    for (int i = 0; i < first.length; i++) {
      if (first[i].userId != second[i].userId ||
          first[i].cardId != second[i].cardId ||
          first[i].distance != second[i].distance) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadCandidates() async {
    if (_loadingCandidates) return;

    setState(() {
      _loadingCandidates = true;
    });

    try {
      final candidates = await _exchangeApiRepository.getCandidates();
      if (!mounted) return;

      if (!_candidatesAreEqual(_candidates, candidates)) {
        setState(() {
          _candidates = candidates;
        });
      }
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _loadingCandidates = false;
        });
      }
    }
  }

  void _startCandidatePolling() {
    _candidatePollingTimer?.cancel();
    _candidatePollingTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_loadingCandidates) return;
        await _loadCandidates();
      },
    );

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      _candidatePollingTimer?.cancel();
      _candidatePollingTimer = null;
    });
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await _subscriptionRepository.getSubscriptionModel();
      if (!mounted) return;

      setState(() {
        _subscription = subscription;
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> _showCandidatePicker() async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ExchangeCandidateBottomSheet(
          initialCandidates: _candidates,
          onSelected: (candidate) {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _startAccelerometerListener() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime).inSeconds < 2) return;

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
        builder: (_) => const HomeScreen(initialIndex: 3),
      ),
          (_) => false,
    );
  }

  Future<void> _showQrDialog(CardModel card) async {
    _isQrDialogOpen = true;
    NotificationService.instance.addExchangeListener(_onExchangeSuccess);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => QrDialog(card: card),
    );

    NotificationService.instance.removeExchangeListener(_onExchangeSuccess);
    _isQrDialogOpen = false;
  }

  Future<void> _startExchange() async {
    if (selectedCard == null || _sending || !_canExchange) return;

    _candidatePollingTimer?.cancel();
    _candidatePollingTimer = null;

    setState(() {
      _sending = true;
    });

    try {
      await _exchangeApiRepository.sendExchange(cardId: selectedCard!.id);
      await _loadCandidates();
      _startCandidatePolling();

      if (!mounted) return;
      await _showCandidatePicker();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    _candidatePollingTimer?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Гарантуємо фонове оновлення візиток при кожному відображенні цього екрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isLoading) {
        loadCards(showLoading: false);
      }
    });

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Якщо у користувача немає жодної візитки
    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 70,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              const Text(
                'Спочатку створіть візитку',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Щоб здійснювати обмін, вам потрібна хоча б одна створена візитка.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCardScreen()),
                  );
                  loadCards();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Створити візитку'),
              ),
            ],
          ),
        ),
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
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: _canExchange
                          ? const Color(0xFFF59E0B)
                          : Colors.grey,
                    ),
                    onPressed: !_canExchange
                        ? null
                        : () {
                      if (selectedCard == null) return;
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
                onPressed: _sending || !_canExchange ? null : _startExchange,
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