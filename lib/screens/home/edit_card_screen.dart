import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/card_model.dart';
import '../../repositories/card_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../widgets/card_text_field.dart';
import '../../widgets/color_circle.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;

  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController fullNameController;
  late TextEditingController positionController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController linkedinController;
  late TextEditingController telegramController;
  late TextEditingController instagramController;
  late TextEditingController githubController;
  late TextEditingController aboutController;

  late Color selectedColor;

  List<Color> allowedColors = [];
  bool isColorsLoading = true;

  bool _showAllColors = false;
  static const int _initialColorsCount = 6;

  final SubscriptionRepository _subscriptionRepository =
  SubscriptionRepository();

  bool showInCatalog = true;
  bool _isSaving = false;
  File? selectedImage;
  final CardRepository _repository = CardRepository();

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(text: widget.card.fullName);
    positionController = TextEditingController(text: widget.card.position);
    companyController = TextEditingController(text: widget.card.company);
    emailController = TextEditingController(text: widget.card.email);
    phoneController = TextEditingController(text: widget.card.phone);
    websiteController = TextEditingController(text: widget.card.website);

    telegramController = TextEditingController(
      text: _extractTelegramUsername(widget.card.telegram),
    );
    instagramController = TextEditingController(
      text: _extractInstagramUsername(widget.card.instagram),
    );
    githubController = TextEditingController(
      text: _extractGithubUsername(widget.card.github),
    );
    linkedinController = TextEditingController(
      text: _extractLinkedinUsername(widget.card.linkedin),
    );

    aboutController = TextEditingController(text: widget.card.about);

    selectedColor = Color(widget.card.cardColor);
    showInCatalog = widget.card.showInCatalog;

    loadAllowedColors();
  }

  Future<void> loadAllowedColors() async {
    try {
      final colors = await _subscriptionRepository.getAllowedColors();

      if (!mounted) return;

      setState(() {
        allowedColors = colors.map((value) => Color(value)).toList();

        final hasCurrentColor = allowedColors.any(
              (c) => c.value == selectedColor.value,
        );

        if (!hasCurrentColor) {
          allowedColors.insert(0, selectedColor);
        }

        isColorsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isColorsLoading = false;
      });

      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
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

  String _extractTelegramUsername(String value) {
    final text = value.trim();
    if (text.isEmpty) return "";
    if (text.startsWith("https://t.me/")) {
      return text.substring("https://t.me/".length).split("/").first;
    }
    if (text.startsWith("http://t.me/")) {
      return text.substring("http://t.me/".length).split("/").first;
    }
    return text.replaceFirst(RegExp(r'^@'), '');
  }

  String _extractInstagramUsername(String value) {
    final text = value.trim();
    if (text.isEmpty) return "";

    const prefixes = [
      "https://www.instagram.com/",
      "https://instagram.com/",
      "http://www.instagram.com/",
      "http://instagram.com/",
    ];

    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        return text.substring(prefix.length).split("/").first;
      }
    }
    return text.replaceFirst(RegExp(r'^@'), '');
  }

  String _extractGithubUsername(String value) {
    final text = value.trim();
    if (text.isEmpty) return "";

    const prefixes = ["https://github.com/", "http://github.com/"];

    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        return text.substring(prefix.length).split("/").first;
      }
    }
    return text.replaceFirst(RegExp(r'^@'), '');
  }

  String _extractLinkedinUsername(String value) {
    final text = value.trim();
    if (text.isEmpty) return "";

    const prefixes = [
      "https://www.linkedin.com/in/",
      "https://linkedin.com/in/",
      "http://www.linkedin.com/in/",
      "http://linkedin.com/in/",
    ];

    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        return text.substring(prefix.length).split("/").first;
      }
    }
    return text.replaceFirst(RegExp(r'^@'), '');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    positionController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    linkedinController.dispose();
    telegramController.dispose();
    instagramController.dispose();
    githubController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> updateCard() async {
    final card = CardModel(
      id: widget.card.id,
      ownerId: widget.card.ownerId,
      fullName: fullNameController.text.trim(),
      position: positionController.text.trim(),
      company: companyController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      website: websiteController.text.trim(),
      linkedin: linkedinController.text.trim(),
      telegram: telegramController.text.trim(),
      instagram: instagramController.text.trim(),
      github: githubController.text.trim(),
      about: aboutController.text.trim(),
      photoUrl: widget.card.photoUrl,
      cardColor: selectedColor.value,
      showInCatalog: showInCatalog,
    );

    await _repository.updateCard(widget.card.id, card, selectedImage);
  }

  ImageProvider? _getAvatarImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }
    if (widget.card.photoUrl.isNotEmpty) {
      return NetworkImage(widget.card.photoUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Редагування візитки',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.05)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Редагування візитки',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _getAvatarImage(),
                      child:
                      selectedImage == null && widget.card.photoUrl.isEmpty
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
                          onPressed: pickImage,
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
                label: 'Повне ім\'я',
                controller: fullNameController,
              ),
              CardTextField(label: 'Посада', controller: positionController),
              CardTextField(label: 'Компанія', controller: companyController),
              CardTextField(
                label: 'Електронна пошта',
                controller: emailController,
              ),
              CardTextField(label: 'Телефон', controller: phoneController),
              CardTextField(label: 'Вебсайт', controller: websiteController),
              CardTextField(label: 'LinkedIn', controller: linkedinController),
              CardTextField(label: 'Telegram', controller: telegramController),
              CardTextField(
                label: 'Instagram',
                controller: instagramController,
              ),
              CardTextField(label: 'GitHub', controller: githubController),
              const SizedBox(height: 8),
              const Text(
                'Про себе',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aboutController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Розкажіть про себе...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Колір візитки',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (isColorsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (allowedColors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Не вдалося отримати кольори з сервера',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _showAllColors
                        ? allowedColors.length
                        : allowedColors.length.clamp(0, _initialColorsCount),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final color = allowedColors[index];

                      return Center(
                        child: ColorCircle(
                          color: color,
                          selected: selectedColor.value == color.value,
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  if (allowedColors.length > _initialColorsCount) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllColors = !_showAllColors;
                          });
                        },
                        icon: Icon(
                          _showAllColors
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFFF59E0B),
                        ),
                        label: Text(
                          _showAllColors
                              ? 'Показати менше'
                              : 'Показати всі (${allowedColors.length})',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Показувати в каталозі'),
                    Switch(
                      value: showInCatalog,
                      activeColor: const Color(0xFFF59E0B),
                      onChanged: (value) {
                        setState(() {
                          showInCatalog = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
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
                      child: const Text('Скасувати'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          await updateCard();

                          if (!mounted) return;

                          Navigator.of(context).pop(true);
                        } catch (e) {
                          if (!mounted) return;

                          setState(() {
                            _isSaving = false;
                          });

                          _showErrorSnackBar(
                            e.toString().replaceAll('Exception: ', ''),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Зберегти'),
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