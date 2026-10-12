import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import '../../repositories/settings_repository.dart';
import '../../widgets/settings_section.dart';
import '../../widgets/settings_tile.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository repository = SettingsRepository();
  bool loading = false;

  static const String _privacyPolicyUrl =
      'https://lanovska-sofiia10.github.io/cardswap-privacy/';

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse(_privacyPolicyUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Не вдалося відкрити $url');
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
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
                Icons.check_circle_outline_rounded,
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
        iconTheme: const IconThemeData(color: Colors.white),
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
            const SettingsSection(title: "Обліковий запис"),
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
                      try {
                        await repository.sendResetPasswordEmail();
                        if (!mounted) return;
                        _showInfoSnackBar("Лист для зміни пароля відправлено на ваш Email.");
                      } catch (e) {
                        if (!mounted) return;
                        _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
                      }
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
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Скасувати"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF59E0B),
                                          ),
                                          onPressed: () => Navigator.pop(context, true),
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
                      if (!mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            /// Візитки
            const SettingsSection(title: "Візитки"),
            _card(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: "Мої візитки",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 0),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.people_outline,
                    title: "Каталог",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 1),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SettingsTile(
                    icon: Icons.contacts_outlined,
                    title: "Контакти",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 3),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            /// Інформація та Правова інформація
            const SettingsSection(title: "Інформація"),
            _card(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Політика конфіденційності",
                    onTap: _openPrivacyPolicy,
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
                    // 1. Перше діалогове вікно — Підтвердження намірiв
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Кругла іконка у червоному контексті
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 38,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Видалити акаунт?",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Ця дія незворотна.\nБуде видалено акаунт, усі візитки, контакти та фотографії.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text(
                                          "Скасувати",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          backgroundColor: const Color(0xFFEF4444),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(
                                          "Видалити",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
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

                    if (result != true || !mounted) return;

                    // 2. Друге діалогове вікно — Введення пароля
                    final password = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Підтвердження",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Для видалення акаунта введіть ваш поточний пароль.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: controller,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: "Пароль",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFF59E0B)),
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
                                          side: BorderSide(color: Colors.grey.shade300),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          "Скасувати",
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(50),
                                          backgroundColor: const Color(0xFFEF4444),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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

                    if (password == null || password.isEmpty || !mounted) return;

                    // 3. Індикатор завантаження під час видалення
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Padding(
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
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    try {
                      await repository.reauthenticate(password);
                      await repository.deleteAccount();

                      if (!mounted) return;

                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                          message = "Повторно увійдіть у свій акаунт та спробуйте ще раз.";
                          break;
                        default:
                          message = "Не вдалося видалити акаунт.";
                      }

                      _showErrorSnackBar(message);
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(context);

                      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
                    }
                  },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withAlpha(13),
          ),
        ],
      ),
      child: child,
    );
  }
}