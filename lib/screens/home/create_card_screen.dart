import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  Color selectedColor = const Color(0xFFF59E0B);
  bool showInCatalog = true;
  File? selectedImage;


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

  Future<void> saveCard() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('cards')
        .doc(user.uid)
        .set({
      'ownerId': user.uid,

      'fullName': fullNameController.text,
      'position': positionController.text,
      'company': companyController.text,

      'phone': phoneController.text,
      'email': emailController.text,
      'website': websiteController.text,

      'linkedin': linkedinController.text,
      'telegram': telegramController.text,
      'instagram': instagramController.text,
      'github': githubController.text,

      'about': aboutController.text,

      'photoUrl': '',

      'cardColor': selectedColor.value,

      'showInCatalog': showInCatalog,

      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'hasCard': true,
    });
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
                  backgroundImage:
                  selectedImage != null
                      ? FileImage(selectedImage!)
                      : null,
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

              _field(
                'Повне ім\'я',
                fullNameController,
              ),

              _field(
                'Посада',
                positionController,
              ),

              _field(
                'Компанія',
                companyController,
              ),

              _field(
                'Електронна пошта',
                emailController,
              ),

              _field(
                'Телефон',
                phoneController,
              ),

              _field(
                'Вебсайт',
                websiteController,
              ),

              _field(
                'LinkedIn',
                linkedinController,
              ),

              _field(
                'Telegram',
                telegramController,
              ),

              _field(
                'Instagram',
                instagramController,
              ),

              _field(
                'GitHub',
                githubController,
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
                    borderRadius:
                    BorderRadius.circular(16),
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

              Row(
                children: [
                  _color(const Color(0xFFF59E0B)),
                  _color(const Color(0xFF60A5FA)),
                  _color(const Color(0xFF34D399)),
                  _color(const Color(0xFFA78BFA)),
                  _color(const Color(0xFFFB7185)),
                  _color(const Color(0xFF22D3EE)),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(16),
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                        const Size.fromHeight(56),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              16),
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
                      onPressed: () async {

                        await saveCard();

                        if (!mounted) return;

                        Navigator.pop(context, true);
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFF59E0B),
                        foregroundColor:
                        Colors.white,
                        minimumSize:
                        const Size.fromHeight(56),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              16),
                        ),
                      ),
                      child: const Text(
                        'Зберегти',
                      ),
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

  Widget _field(
      String label,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _color(Color color) {
    final selected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
            color: Colors.black,
            width: 2,
          )
              : null,
        ),
      ),
    );
  }
}