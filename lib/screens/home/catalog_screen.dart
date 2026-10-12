import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../models/catalog_data.dart';
import '../../repositories/catalog_repository.dart';
import '../../widgets/card_details_screen.dart';
import '../../widgets/catalog_card_widget.dart';
import '../../widgets/catalog_contact_card_widget.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController searchController = TextEditingController();
  final CatalogRepository _catalogRepository = CatalogRepository();

  List<CardModel> cards = [];
  List<CardModel> filtered = [];
  List<CardModel> myCards = [];
  final Map<String, ContactState> contactStates = {};

  ContactState _getState(String myCardId, String targetCardId) {
    return contactStates['$myCardId|$targetCardId'] ?? ContactState.none;
  }

  ContactState _getUserState(String targetCardId) {
    for (final myCard in myCards) {
      final state = _getState(myCard.id, targetCardId);
      if (state == ContactState.connected) {
        return ContactState.connected;
      }
    }

    for (final myCard in myCards) {
      final state = _getState(myCard.id, targetCardId);
      if (state == ContactState.pendingOutgoing) {
        return ContactState.pendingOutgoing;
      }
    }

    for (final myCard in myCards) {
      final state = _getState(myCard.id, targetCardId);
      if (state == ContactState.pendingIncoming) {
        return ContactState.pendingIncoming;
      }
    }

    return ContactState.none;
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(search);
  }

  void search() {
    final q = searchController.text.toLowerCase().trim();
    setState(() {
      filtered = cards.where((card) {
        return card.fullName.toLowerCase().contains(q) ||
            card.position.toLowerCase().contains(q) ||
            card.company.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _handleSendRequest(String myCardId, String targetCardId) async {
    try {
      await _catalogRepository.sendRequest(myCardId, targetCardId);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> _handleCancelRequest(String targetCardId) async {
    try {
      await _catalogRepository.cancelRequest(targetCardId);
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

  void _showCardPicker(CardModel targetCard) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: myCards.length > 3 ? 500 : null,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    "Оберіть візитку",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...myCards.map((card) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _handleSendRequest(card.id, targetCard.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CatalogCardWidget(card: card),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CatalogData>(
      stream: _catalogRepository.catalogStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        myCards = data.myCards;
        cards = data.catalogCards;
        contactStates
          ..clear()
          ..addAll(data.contactStates);

        final q = searchController.text.toLowerCase().trim();
        filtered = cards.where((card) {
          return card.fullName.toLowerCase().contains(q) ||
              card.position.toLowerCase().contains(q) ||
              card.company.toLowerCase().contains(q);
        }).toList();

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Публічний каталог",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Всі візитки",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: searchController,
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text("Нічого не знайдено"))
                    : ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 30,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final card = filtered[index];
                    final userState = _getUserState(card.id);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardDetailsScreen(
                              card: card,
                              canViewContacts:
                              userState == ContactState.connected,
                              state: userState,
                              onSendRequest: () async {
                                if (myCards.isEmpty) return;
                                if (myCards.length == 1) {
                                  await _handleSendRequest(
                                    myCards.first.id,
                                    card.id,
                                  );
                                } else {
                                  _showCardPicker(card);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: CatalogContactCardWidget(
                        card: card,
                        state: userState,
                        onPressed: () async {
                          switch (userState) {
                            case ContactState.none:
                              if (myCards.isEmpty) return;
                              if (myCards.length == 1) {
                                await _handleSendRequest(
                                  myCards.first.id,
                                  card.id,
                                );
                              } else {
                                _showCardPicker(card);
                              }
                              break;

                            case ContactState.pendingOutgoing:
                              await _handleCancelRequest(card.id);
                              break;

                            case ContactState.pendingIncoming:
                            case ContactState.connected:
                              break;
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}