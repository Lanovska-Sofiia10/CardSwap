import 'package:flutter/material.dart';

import '../../models/user_profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/profile_info_tile.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  UserProfileModel? profile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final result = await _repository.loadProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");

      if (!mounted) return;

      final cleanError = e.toString().replaceAll("Exception: ", "");

      setState(() {
        isLoading = false;
        errorMessage = cleanError;
      });

      _showErrorSnackBar(cleanError);
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

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Профіль",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
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
                errorMessage.isNotEmpty
                    ? errorMessage
                    : "Не вдалося завантажити профіль",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadProfile,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return _buildErrorState();
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
          "Профіль",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    profile: profile!,
                  ),
                ),
              );

              if (updated == true) {
                loadProfile();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: profile!.photoUrl.isNotEmpty
                  ? NetworkImage(profile!.photoUrl)
                  : null,
              child: profile!.photoUrl.isEmpty
                  ? const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              )
                  : null,
            ),
            const SizedBox(height: 18),
            Text(
              profile!.displayName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile!.position,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    color: Colors.black.withAlpha(15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileInfoTile(
                    icon: Icons.person_outline,
                    title: "Ім'я користувача",
                    value: profile!.displayName,
                  ),
                  const Divider(height: 1),
                  ProfileInfoTile(
                    icon: Icons.badge_outlined,
                    title: "Повне ім'я",
                    value: profile!.fullName,
                  ),
                  const Divider(height: 1),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: profile!.email,
                  ),
                  const Divider(height: 1),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    title: "Телефон",
                    value: profile!.phone,
                  ),
                  const Divider(height: 1),
                  ProfileInfoTile(
                    icon: Icons.work_outline,
                    title: "Посада",
                    value: profile!.position,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}