import 'package:flutter/material.dart';
import '../repositories/home_repository.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/settings_screen.dart' hide ProfileScreen;
import '../screens/profile/profile_screen.dart';
import 'logout_dialog.dart';

class HomeDrawer extends StatelessWidget {
  HomeDrawer({
    super.key,
  });

  final HomeRepository repository = HomeRepository();

  Future<void> _logout(BuildContext context) async {
    await repository.logout();

    if (!context.mounted) return;

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
                page: ProfileScreen(),
              ),
              _drawerPage(
                context,
                icon: Icons.settings_outlined,
                title: "Налаштування",
                page: SettingsScreen(),
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
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => const LogoutDialog(),
                        );

                        if (confirm == true && context.mounted) {
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
        leading: Icon(
          icon,
          color: Colors.white70,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
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