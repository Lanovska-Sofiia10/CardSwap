import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/card_model.dart';
import '../../widgets/card_view_widget.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  List<CardModel> _contacts = [];
  List<CardModel> _filteredContacts = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_filterContacts);

    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('contacts')
          .where(
        'ownerUserId',
        isEqualTo: currentUser.uid,
      )
          .get();

      List<CardModel> cards = [];

      for (final doc in contactsSnapshot.docs) {
        final contactCardId = doc['contactCardId'];

        final cardDoc = await FirebaseFirestore.instance
            .collection('cards')
            .doc(contactCardId)
            .get();

        if (cardDoc.exists) {
          cards.add(
            CardModel.fromJson(
              cardDoc.data()!,
              cardDoc.id,
            ),
          );
        }
      }

      setState(() {
        _contacts = cards;
        _filteredContacts = cards;
      });
    } catch (e) {
      print('LOAD CONTACTS ERROR: $e');
    }
  }
  void _filterContacts() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredContacts = _contacts.where((card) {
        return card.fullName
            .toLowerCase()
            .contains(query) ||
            card.position
                .toLowerCase()
                .contains(query) ||
            card.company
                .toLowerCase()
                .contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                    "Збережені візитки (${_contacts.length})",
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
                      style: const TextStyle(
                        fontSize: 16,
                      ),
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
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _filteredContacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding:
                const EdgeInsets.all(16),
                itemCount:
                _filteredContacts.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  final card =
                  _filteredContacts[index];

                  return CardViewWidget(
                    card: card,
                  );
                },
              ),
            ),
          ],
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
}