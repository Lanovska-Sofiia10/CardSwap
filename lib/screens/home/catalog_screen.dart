import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/catalog_card_widget.dart';
import '../../models/card_model.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {

  final TextEditingController searchController =
  TextEditingController();

  List<CardModel> cards = [];
  List<CardModel> filtered = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadCards();

    searchController.addListener(search);
  }

  Future<void> loadCards() async {

    final user =
        FirebaseAuth.instance.currentUser;

    final snapshot =
    await FirebaseFirestore.instance
        .collection('cards')
        .get();

    cards = snapshot.docs
        .map(
          (e) => CardModel.fromJson(
        e.data(),
        e.id,
      ),
    )

        .where(
          (card) =>
      card.ownerId != user?.uid &&
          card.showInCatalog,
    )

        .toList();

    filtered = cards;

    setState(() {
      loading = false;
    });
  }

  void search() {

    final q =
    searchController.text
        .toLowerCase();

    setState(() {

      filtered =
          cards.where((card) {

            return card.fullName
                .toLowerCase()
                .contains(q) ||

                card.position
                    .toLowerCase()
                    .contains(q) ||

                card.company
                    .toLowerCase()
                    .contains(q);

          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Column(
        children: [

          Padding(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(
                  "Публічний каталог",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  "Всі візитки",
                  style: TextStyle(
                    color:
                    Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

      TextField(
        controller: searchController,
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
            child:
            filtered.isEmpty

                ? const Center(
              child:
              Text(
                "Нічого не знайдено",
              ),
            )

                : ListView.separated(

              padding:
              const EdgeInsets
                  .only(
                left: 16,
                right: 16,
                bottom: 30,
              ),

              itemCount:
              filtered.length,

              separatorBuilder:
                  (_, __) =>
              const SizedBox(
                height: 18,
              ),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                    return CatalogCardWidget(
                      card: filtered[index],
                    );              },
            ),
          ),
        ],
      ),
    );
  }
}