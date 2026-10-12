import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/card_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();

  late TextEditingController displayNameController;
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController positionController;

  File? selectedImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    fullNameController = TextEditingController(
      text: widget.profile.fullName,
    );
    phoneController = TextEditingController(
      text: widget.profile.phone,
    );
    positionController = TextEditingController(
      text: widget.profile.position,
    );
  }

  @override
  void dispose() {
    displayNameController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    positionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
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

  Future<void> _save() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await _repository.updateProfile(
        displayName: displayNameController.text.trim(),
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        position: positionController.text.trim(),
        photo: selectedImage,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final cleanError = e.toString().replaceAll("Exception: ", "");
      _showErrorSnackBar(
        cleanError.isNotEmpty ? cleanError : "Не вдалося оновити профіль",
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  ImageProvider? _getAvatarImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }
    if (widget.profile.photoUrl.isNotEmpty) {
      return NetworkImage(widget.profile.photoUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasNoPhoto = selectedImage == null && widget.profile.photoUrl.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Редагування профілю',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withAlpha(13),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Редагування профілю',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _getAvatarImage(),
                      child: hasNoPhoto
                          ? const Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: isSaving ? null : pickImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CardTextField(
                label: "Ім'я користувача",
                controller: displayNameController,
              ),
              CardTextField(
                label: "Повне ім'я",
                controller: fullNameController,
              ),
              CardTextField(
                label: "Телефон",
                controller: phoneController,
              ),
              CardTextField(
                label: "Посада",
                controller: positionController,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Скасувати"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text("Зберегти"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}