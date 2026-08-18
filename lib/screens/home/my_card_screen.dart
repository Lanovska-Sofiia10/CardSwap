import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'create_card_screen.dart';
import '../../widgets/card_view_widget.dart';
import 'edit_card_screen.dart';
import '../../repositories/card_repository.dart';
import '../../widgets/card_details_screen.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  List<CardModel> cards = [];
  bool isLoading = true;

  final CardRepository _repository =
  CardRepository();

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    try {
      final result = await _repository.getMyCards();

      if (!mounted) return;

      setState(() {
        cards = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : cards.isEmpty
          ? _buildEmptyState(context)
          : _buildCardsView(),
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
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.05),
              )
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (cards.length < 2)
          _buildCreateButtonSmall(),
      ],
    );
  }


  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCardScreen(),
            ),
          );

          if (result == true) {
            loadCards();
          }
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButtonSmall() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCardScreen(),
            ),
          );

          if (result == true) {
            loadCards();
          }
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
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
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
          return Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
            ],
          );
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
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onSelected: (value) async {

              if (value == 'view') {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailsScreen(
                      card: card,
                      canViewContacts: true,
                    ),
                  ),
                );

              }

              if (value == 'edit') {

                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCardScreen(
                      card: card,
                    ),
                  ),
                );

                if (result == true) {
                  loadCards();
                }
              }

              if (value == 'delete') {

                await _repository.deleteCard(card.id);

                await loadCards();
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
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
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
                  children: const [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.black,
                      size: 20,
                    ),
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