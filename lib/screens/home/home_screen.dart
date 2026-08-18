import 'package:flutter/material.dart';
import 'my_card_screen.dart';
import 'catalog_screen.dart';
import 'exchange_screen.dart';
import 'contacts_screen.dart';
import 'notifications_screen.dart';
import '../../widgets/home_drawer.dart';
import '../../repositories/home_repository.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey =
  GlobalKey<ScaffoldState>();

  final HomeRepository repository =
  HomeRepository();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  final screens = const [
    MyCardScreen(),
    CatalogScreen(),
    ExchangeScreen(),
    ContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xfff8fafc),

        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,

          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),

          title: const Text(
            "CardSwap",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          centerTitle: true,

          actions: [

        StreamBuilder<bool>(
        stream: repository.hasUnreadRequests(),
      builder: (context, snapshot) {

        final hasUnread =
            snapshot.data ?? false;

        return IconButton(
          onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NotificationsScreen(),
              ),
            );

          },
          icon: Icon(
            hasUnread
                ? Icons.notifications_rounded
                : Icons.notifications_none_rounded,
            color: Colors.white,
          ),
        );
      },
    ),

            const SizedBox(width: 8),
          ],
        ),

      drawer: HomeDrawer(),

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFF59E0B),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              label: 'Моя візитка',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Каталог',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Обмін',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              label: 'Контакти',
            ),
          ],
        ),
      ),
    );
  }
}