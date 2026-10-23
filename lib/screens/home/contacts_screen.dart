import 'package:flutter/material.dart';
import '../../widgets/card_details_screen.dart';
import '../../widgets/card_view_widget.dart';
import '../../repositories/contact_repository.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchText = ValueNotifier<String>("");
  final ContactRepository _contactRepository = ContactRepository();

  List<ContactItem>? _localContacts;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchText.value = _searchController.text.toLowerCase();
    });
  }

  List<ContactItem> _filterContacts(List<ContactItem> items, String searchText) {
    if (searchText.isEmpty) {
      return items;
    }

    return items.where((item) {
      final card = item.card;
      return card.fullName.toLowerCase().contains(searchText) ||
          card.position.toLowerCase().contains(searchText) ||
          card.company.toLowerCase().contains(searchText);
    }).toList();
  }

  Future<void> _handleDeleteContact(ContactItem item) async {
    setState(() {
      _localContacts?.removeWhere((c) => c.contactCardId == item.contactCardId);
    });

    try {
      await _contactRepository.deleteContact(item.contactCardId);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
    }
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
        child: StreamBuilder<List<ContactItem>>(
          stream: _contactRepository.contactsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _localContacts == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && _localContacts == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString().replaceAll("Exception: ", ""),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {});
                        },
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

            if (snapshot.hasData) {
              _localContacts = snapshot.data;
            }

            final allContacts = _localContacts ?? [];

            return ValueListenableBuilder<String>(
              valueListenable: _searchText,
              builder: (context, searchText, _) {
                final contacts = _filterContacts(allContacts, searchText);

                return Column(
                  children: [
                    _buildHeader(allContacts.length),
                    Expanded(
                      child: contacts.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: contacts.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                        itemBuilder: (_, index) {
                          final item = contacts[index];
                          final card = item.card;

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
                                CardViewWidget(card: card),
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
                                                  "Контакт\n${card.fullName}\nбуде видалено з вашого списку.",
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
                                        await _handleDeleteContact(item);
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
    _searchText.dispose();
    super.dispose();
  }
}