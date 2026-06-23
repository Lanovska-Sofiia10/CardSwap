import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'my_card_screen.dart';
import 'catalog_screen.dart';
import 'exchange_screen.dart';
import 'contacts_screen.dart';

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

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

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

          title: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF59E0B),
                child: Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              SizedBox(width: 12),

              Text(
                'CardSwap',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),

      drawer: Drawer(
        child: Container(
          color: const Color(0xFF0F172A),

          child: SafeArea(
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [

                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFF59E0B),
                        child: Icon(
                          Icons.badge_outlined,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          "CardSwap",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _drawerItem(
                  icon: Icons.badge_outlined,
                  title: "Моя візитка",
                  index: 0,
                ),

                _drawerItem(
                  icon: Icons.people_outline,
                  title: "Каталог",
                  index: 1,
                ),

                _drawerItem(
                  icon: Icons.swap_horiz,
                  title: "Обмін",
                  index: 2,
                ),

                _drawerItem(
                  icon: Icons.contacts_outlined,
                  title: "Контакти",
                  index: 3,
                ),

                const Spacer(),

                const Divider(color: Colors.white24),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'UA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      const Text(
                        'EN',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);

                          final confirm =
                          await showDialog<bool>(
                            context: context,
                              builder: (_) => Dialog(
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
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      const Text(
                                        'Вихід з акаунта',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        'Ви дійсно хочете вийти зі свого акаунта?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFF59E0B),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                              ),
                                              child: const Text(
                                                'Скасувати',
                                                style: TextStyle(
                                                  color: Color(0xFFF59E0B),
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
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                              ),
                                              child: const Text('Вийти'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          );

                          if (confirm == true) {
                            await logout();
                          }
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Вийти",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        tileColor: selected
            ? const Color(0xFFF59E0B)
            : Colors.transparent,

        leading: Icon(
          icon,
          color: selected
              ? Colors.white
              : Colors.white70,
        ),

        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        onTap: () {
          setState(() {
            currentIndex = index;
          });

          Navigator.pop(context);
        },
      ),
    );
  }
}