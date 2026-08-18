import 'package:flutter/material.dart';

import '../../models/user_profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/profile_info_tile.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final ProfileRepository _repository =
  ProfileRepository();

  UserProfileModel? profile;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    profile = await _repository.loadProfile();

    print(profile);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: Text("Профіль не знайдено"),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      profile: profile!,
                    ),
                  ),
                );

                loadProfile();
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