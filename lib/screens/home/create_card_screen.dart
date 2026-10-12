import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/card_model.dart';
import '../../repositories/card_repository.dart';
import '../../repositories/subscription_repository.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final fullNameController = TextEditingController();
  final positionController = TextEditingController();
  final companyController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final linkedinController = TextEditingController();
  final telegramController = TextEditingController();
  final instagramController = TextEditingController();
  final githubController = TextEditingController();
  final aboutController = TextEditingController();

  bool _isSaving = false;

  Color? selectedColor;
  List<Color> allowedColors = [];
  bool isColorsLoading = true;

  bool _showAllColors = false;

  static const int _initialColorsCount = 6;

  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  bool showInCatalog = true;
  File? selectedImage;
  final CardRepository repository = CardRepository();

  @override
  void initState() {
    super.initState();
    loadAllowedColors();
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

  Color _parseColor(dynamic rawColor) {
    if (rawColor is int) {
      return Color(rawColor);
    } else if (rawColor is String) {
      String hex = rawColor.replaceAll('#', '').replaceAll('0x', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return const Color(0xFFF59E0B);
  }

  Future<void> loadAllowedColors() async {
    try {
      final dynamic response = await _subscriptionRepository.getAllowedColors();

      List rawList = [];

      if (response is List) {
        rawList = response;
      } else if (response is Map) {
        if (response['data'] != null && response['data'] is Map) {
          final data = response['data'] as Map;
          if (data['limits'] != null && data['limits'] is Map) {
            rawList = data['limits']['allowedColors'] ?? [];
          } else if (data['allowedColors'] is List) {
            rawList = data['allowedColors'];
          }
        } else if (response['limits'] != null && response['limits'] is Map) {
          rawList = response['limits']['allowedColors'] ?? [];
        } else if (response['allowedColors'] is List) {
          rawList = response['allowedColors'];
        }
      }

      final List<Color> parsed =
      rawList.map((item) => _parseColor(item)).toList();

      if (!mounted) return;

      setState(() {
        allowedColors = parsed;
        if (allowedColors.isNotEmpty) {
          selectedColor = allowedColors.first;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Створення візитки',
          style: TextStyle(color: Colors.white),
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
                color: Colors.black.withOpacity(0.05),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Інформація про візитку',
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
                      backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                      child: selectedImage == null
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
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _field('Повне ім\'я', fullNameController),
              _field('Посада', positionController),
              _field('Компанія', companyController),
              _field('Електронна пошта', emailController),
              _field('Телефон', phoneController),
              _field('Вебсайт', websiteController),
              _field('LinkedIn', linkedinController),
              _field('Telegram', telegramController),
              _field('Instagram', instagramController),
              _field('GitHub', githubController),
              const SizedBox(height: 8),
              const Text(
                'Про себе',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
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
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final color = allowedColors[index];
                      return Center(
                        child: _color(color),
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
                      onPressed: () {
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
                      onPressed: (_isSaving || selectedColor == null)
                          ? null
                          : () async {
                        setState(() {
                          _isSaving = true;
                        });

                        final int colorValueForBackend =
                        selectedColor!.value.toUnsigned(32);

                        final card = CardModel(
                          id: '',
                          ownerId: '',
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
                          photoUrl: '',
                          cardColor: colorValueForBackend,
                          showInCatalog: showInCatalog,
                        );

                        try {
                          await repository.createCard(
                            card,
                            selectedImage,
                          );

                          if (!mounted) return;
                          Navigator.pop(context, true);
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

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _color(Color color) {
    final selected = selectedColor?.value == color.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
            color: Colors.black,
            width: 2.5,
          )
              : null,
        ),
      ),
    );
  }
}