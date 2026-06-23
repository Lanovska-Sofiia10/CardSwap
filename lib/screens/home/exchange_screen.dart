import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/card_model.dart';
import '../../widgets/catalog_card_widget.dart';
import 'contacts_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'home_screen.dart';
import 'scan_qr_screen.dart';
import 'dart:async';

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
  int _contactsCountBeforeExchange = 0;

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final snapshot =
    await FirebaseFirestore.instance
        .collection('cards')
        .where(
      'ownerId',
      isEqualTo: user.uid,
    )
        .get();

    cards = snapshot.docs
        .map(
          (doc) => CardModel.fromJson(
        doc.data(),
        doc.id,
      ),
    )
        .toList();

    if (cards.isNotEmpty) {
      selectedCard = cards.first;
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _showQrDialog(CardModel card) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('contacts')
          .where('ownerUserId', isEqualTo: user.uid)
          .get();

      _contactsCountBeforeExchange = snapshot.docs.length;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
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
        );      },
    );

    _exchangeSubscription?.cancel();

    _listenForExchange(card.id);
  }

  StreamSubscription? _exchangeSubscription;

  void _listenForExchange(String cardId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    _exchangeSubscription?.cancel();

    _exchangeSubscription = FirebaseFirestore.instance
        .collection('contacts')
        .where('ownerUserId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.length > _contactsCountBeforeExchange) {

        _exchangeSubscription?.cancel();

        if (!mounted) return;

        Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(
              initialIndex: 3,
            ),
          ),
              (route) => false,
        );
      }
    });
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
      builder: (context) {
        return SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: cards.length > 3 ? 500 : null,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Text(
                        'Оберіть візитку',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ...cards.map((card) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCard = card;
                            });

                            Navigator.pop(context);
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: CatalogCardWidget(card: card),
                              ),

                              if (selectedCard?.id == card.id)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );                      }),
                    ],
                  ),
                ),
            ),
        );
      },
    );
  }

  @override
  void dispose() {
    _exchangeSubscription?.cancel();
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
                onPressed: () {},
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

          const SizedBox(height: 90),

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

          // Тут буде твій CatalogCardWidget
        if (selectedCard != null)
            CatalogCardWidget(
              card: selectedCard!,
        ),
        ],
      ),
    );
  }
}