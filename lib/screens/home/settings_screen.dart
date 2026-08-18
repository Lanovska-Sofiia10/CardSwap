import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../repositories/settings_repository.dart';
import '../../widgets/settings_section.dart';
import '../../widgets/settings_tile.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final SettingsRepository repository =
  SettingsRepository();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            "Налаштування",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Обліковий запис
            const SettingsSection(
              title: "Обліковий запис",
            ),

            _card(
              child: Column(
                children: [

                  SettingsTile(
                    icon: Icons.person_outline,
                    title: "Email",
                    subtitle: repository.email,
                  ),

                  const Divider(height: 1),

                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: "Змінити пароль",
                    onTap: () async {

                      await repository.sendResetPasswordEmail();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Лист для зміни пароля відправлено.",
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  SettingsTile(
                    icon: Icons.logout,
                    title: "Вийти",
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  const Icon(
                                    Icons.logout_rounded,
                                    size: 60,
                                    color: Color(0xFFF59E0B),
                                  ),

                                  const SizedBox(height: 18),

                                  const Text(
                                    "Вийти з акаунта?",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    "Ви впевнені, що хочете завершити сеанс?",
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 24),

                                  Row(
                                    children: [

                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Скасувати"),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF59E0B),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text(
                                            "Вийти",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      if (result != true) return;

                      await repository.signOut();
                    },
                  ),
                ],
              ),
            ),

            /// Візитки
            const SettingsSection(
              title: "Візитки",
            ),

            _card(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: "Мої візитки",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(
                            initialIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  SettingsTile(
                    icon: Icons.people_outline,
                    title: "Каталог",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(
                            initialIndex: 1,
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  SettingsTile(
                    icon: Icons.contacts_outlined,
                    title: "Контакти",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(
                            initialIndex: 3,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// Інформація
            const SettingsSection(
              title: "Інформація",
            ),

            _card(
              child: Column(
                children: [

                  SettingsTile(
                    icon: Icons.info_outline,
                    title: "Про застосунок",
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  const SettingsTile(
                    icon: Icons.phone_android,
                    title: "Версія",
                    subtitle: "1.0.0",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _card(
              child: SettingsTile(
                icon: Icons.delete_outline,
                title: "Видалити акаунт",
                isDestructive: true,
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 64,
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Видалити акаунт?",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                "Ця дія незворотна.\n"
                                    "Буде видалено акаунт, усі візитки, контакти та фотографії.",
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text("Скасувати"),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text(
                                        "Видалити",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (result != true) return;

                  if (!mounted) return;

                  // Показуємо індикатор завантаження
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    Navigator.pop(context); // закриваємо індикатор

                    final passwordController = TextEditingController();

                    final password = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();

                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.red,
                                    size: 42,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  "Видалення акаунта",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  "Для підтвердження введіть пароль від свого акаунта.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                TextField(
                                  controller: controller,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: "Пароль",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  children: [

                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Скасувати"),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          minimumSize: const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                            controller.text.trim(),
                                          );
                                        },
                                        child: const Text(
                                          "Видалити",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (password == null || password.isEmpty) return;

// красивий індикатор
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Dialog(
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              CircularProgressIndicator(
                                color: Color(0xFFF59E0B),
                              ),

                              SizedBox(height: 20),

                              Text(
                                "Видаляємо акаунт...",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    await repository.reauthenticate(password);

                    await repository.deleteAccount();

                    if (!mounted) return;

                    Navigator.pop(context); // закриваємо loader
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;

                    Navigator.pop(context);

                    String message;

                    switch (e.code) {
                      case "wrong-password":
                      case "invalid-credential":
                        message = "Невірний пароль.";
                        break;

                      case "requires-recent-login":
                        message =
                        "Повторно увійдіть у свій акаунт та спробуйте ще раз.";
                        break;

                      default:
                        message = "Не вдалося видалити акаунт.";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: child,
    );
  }
}