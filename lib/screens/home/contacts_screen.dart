import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../widgets/card_details_screen.dart';
import '../../widgets/card_view_widget.dart';
import '../../repositories/contact_repository.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController =
  TextEditingController();
  String _searchText = "";

  final ContactRepository _contactRepository =
  ContactRepository();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  List<CardModel> _filterCards(List<CardModel> cards) {
    if (_searchText.isEmpty) {
      return cards;
    }

    return cards.where((card) {
      return card.fullName
          .toLowerCase()
          .contains(_searchText) ||
          card.position
              .toLowerCase()
              .contains(_searchText) ||
          card.company
              .toLowerCase()
              .contains(_searchText);
    }).toList();
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Мої контакти",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Збережені візитки ($count)",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Пошук...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: StreamBuilder<List<CardModel>>(
          stream: _contactRepository.contactsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            List<CardModel> cards =
            _filterCards(snapshot.data ?? []);

            return Column(
              children: [
                _buildHeader(snapshot.data?.length ?? 0),

                Expanded(
                  child: cards.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cards.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final card = cards[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardDetailsScreen(
                                card: card,
                                canViewContacts: true,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [

                            CardViewWidget(
                              card: card,
                            ),

                            Positioned(
                              right: 16,
                              top: 16,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                                onPressed: () async {

                                  final delete = await showDialog<bool>(
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
                                              "Видалити контакт?",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            Text(
                                              "Контакт\n${card.fullName}\nбуде видалено у вас та у користувача, з яким ви обмінялися візитками.",
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
                                                    onPressed: () {
                                                      Navigator.pop(context, false);
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(50),
                                                      side: BorderSide(
                                                        color: Colors.grey.shade300,
                                                      ),
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
                                                    onPressed: () {
                                                      Navigator.pop(context, true);
                                                    },
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
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
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

                                  if (delete == true) {
                                    await _contactRepository.deleteContact(card.id);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_page_outlined,
            size: 70,
            color: Colors.grey.shade500,
          ),

          const SizedBox(height: 16),

          const Text(
            'Поки що немає контактів',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Потрясіть телефон або свайпніть,\nщоб обмінятись візитками',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}