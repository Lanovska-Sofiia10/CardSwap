import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'create_card_screen.dart';
import '../../widgets/card_view_widget.dart';
import 'edit_card_screen.dart';
import '../../repositories/card_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../widgets/card_details_screen.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  List<CardModel> cards = [];
  bool isLoading = true;
  bool hasError = false;
  bool _isFetching = false;
  String errorMessage = '';
  int cardLimit = 2;

  final CardRepository _repository = CardRepository();
  final SubscriptionRepository _subscriptionRepository =
  SubscriptionRepository();

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards({bool showLoading = true}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (showLoading && cards.isEmpty) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      final result = await _repository.getMyCards();
      final subscription = await _subscriptionRepository.getMySubscription();

      final limits = Map<String, dynamic>.from(subscription['limits'] ?? {});
      final backendCardLimit = (limits['cards'] as num?)?.toInt() ?? 2;

      if (!mounted) return;

      setState(() {
        cards = result;
        cardLimit = backendCardLimit;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        isLoading = false;
        if (cards.isEmpty) {
          hasError = true;
          errorMessage = msg;
        }
      });
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _deleteCard(String cardId) async {
    final index = cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = cards[index];

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4DB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFF59E0B),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Видалити візитку?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Візитку\n${card.fullName}\nбуде видалено з вашого списку.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Скасувати",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Видалити",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() {
      cards.removeAt(index);
    });

    try {
      await _repository.deleteCard(cardId);
      await loadCards(showLoading: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cards.insert(index, card);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
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
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: (focused) {
        if (focused) {
          loadCards(showLoading: false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff8fafc),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? _buildErrorState()
            : cards.isEmpty
            ? _buildEmptyState(context)
            : _buildCardsView(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : "Неможливо завантажити дані",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => loadCards(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Спробувати знову"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.05)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 80,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 20),
              const Text(
                "У вас ще немає візитки",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Створіть свою цифрову візитку та почніть обмін контактами",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Мої візитки",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        if (cards.length < cardLimit) _buildCreateButtonSmall(),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Створити візитку",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCreateButtonSmall() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCardScreen()),
          );
          loadCards();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: const Text("Створити"),
      ),
    );
  }

  Widget _buildCardsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(children: [_buildHeader(), const SizedBox(height: 20)]);
        }

        final card = cards[index - 1];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildCardItem(card),
        );
      },
    );
  }

  Widget _buildCardItem(CardModel card) {
    return Stack(
      children: [
        CardViewWidget(card: card),
        Positioned(
          right: 16,
          top: 16,
          child: PopupMenuButton<String>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black26,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              if (value == 'view') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CardDetailsScreen(card: card, canViewContacts: true),
                  ),
                );
              }

              if (value == 'edit') {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => EditCardScreen(card: card)),
                );

                if (result == true) {
                  loadCards();
                }
              }

              if (value == 'delete') {
                await _deleteCard(card.id);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Переглянути',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.black, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Редагувати',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.black, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Видалити',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}