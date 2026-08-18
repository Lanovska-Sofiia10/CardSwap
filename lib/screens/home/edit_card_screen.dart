import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/card_model.dart';
import '../../repositories/card_repository.dart';
import '../../widgets/card_text_field.dart';
import '../../widgets/color_circle.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;

  const EditCardScreen({
    super.key,
    required this.card,
  });

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

  final List<Color> cardColors = const [
    Color(0xFFF59E0B),
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFA78BFA),
    Color(0xFFFB7185),
    Color(0xFF22D3EE),
  ];

  bool showInCatalog = true;

  bool _isSaving = false;
  File? selectedImage;
  final CardRepository _repository =
  CardRepository();

  @override
  void initState() {
    super.initState();

    fullNameController =
        TextEditingController(text: widget.card.fullName);

    positionController =
        TextEditingController(text: widget.card.position);

    companyController =
        TextEditingController(text: widget.card.company);

    emailController =
        TextEditingController(text: widget.card.email);

    phoneController =
        TextEditingController(text: widget.card.phone);

    websiteController =
        TextEditingController(text: widget.card.website);

    linkedinController =
        TextEditingController(text: widget.card.linkedin);

    telegramController =
        TextEditingController(text: widget.card.telegram);

    instagramController =
        TextEditingController(text: widget.card.instagram);

    githubController =
        TextEditingController(text: widget.card.github);

    aboutController =
        TextEditingController(text: widget.card.about);

    selectedColor = Color(widget.card.cardColor);

    showInCatalog = widget.card.showInCatalog;
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

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

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

    await _repository.updateCard(
      widget.card.id,
      card,
      selectedImage,
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
          'Редагування візитки',
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
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Редагування візитки',
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
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (widget.card.photoUrl.isNotEmpty
                      ? NetworkImage(widget.card.photoUrl)
                      : null) as ImageProvider?,
                  child: selectedImage == null &&
                      widget.card.photoUrl.isEmpty
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

              CardTextField(
                label: 'Посада',
                controller: positionController,
              ),

              CardTextField(
                label: 'Компанія',
                controller: companyController,
              ),

              CardTextField(
                label: 'Електронна пошта',
                controller: emailController,
              ),

              CardTextField(
                label: 'Телефон',
                controller: phoneController,
              ),

              CardTextField(
                label: 'Вебсайт',
                controller: websiteController,
              ),

              CardTextField(
                label: 'LinkedIn',
                controller: linkedinController,
              ),

              CardTextField(
                label: 'Telegram',
                controller: telegramController,
              ),

              CardTextField(
                label: 'Instagram',
                controller: instagramController,
              ),

              CardTextField(
                label: 'GitHub',
                controller: githubController,
              ),

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

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cardColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // рівно 6 кольорів у рядку
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final color = cardColors[index];

                return Center(
                  child: ColorCircle(
                    color: color,
                    selected: selectedColor == color,
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                );
              },
            ),

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
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      'Показувати в каталозі',
                    ),

                    Switch(
                      value: showInCatalog,

                      activeColor:
                      const Color(0xFFF59E0B),

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
                        minimumSize:
                        const Size.fromHeight(56),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),

                      child: const Text(
                        'Скасувати',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {

                          if (_isSaving) return;

                          setState(() {
                            _isSaving = true;
                          });

                          try {
                            await updateCard();

                            if (!mounted) return;

                            Navigator.of(context).pop(true);

                          } catch (e) {

                            if (mounted) {
                              setState(() {
                                _isSaving = false;
                              });
                            }

                            print('ERROR: $e');

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFF59E0B),

                        foregroundColor: Colors.white,

                        minimumSize:
                        const Size.fromHeight(56),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
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