import 'package:flutter/material.dart';
import '../repositories/home_repository.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'logout_dialog.dart';

class HomeDrawer extends StatelessWidget {
  HomeDrawer({
    super.key,
  });

  final HomeRepository repository = HomeRepository();

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();

    await repository.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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

              _drawerPage(
                context,
                icon: Icons.person_outline,
                title: "Профіль",
                page: const ProfileScreen(),
              ),

              _drawerPage(
                context,
                icon: Icons.settings_outlined,
                title: "Налаштування",
                page: const SettingsScreen(),
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
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => const LogoutDialog(),
                        );

                        if (confirm == true) {
                          await _logout(context);
                        }
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Вийти',
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
    );
  }

  Widget _drawerPage(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget page,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: const Icon(
          Icons.circle,
          size: 0,
          color: Colors.transparent,
        ),
        title: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}