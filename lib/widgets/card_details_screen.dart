import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/card_model.dart';
import 'catalog_contact_card_widget.dart';

class CardDetailsScreen extends StatefulWidget {
  final CardModel card;
  final bool canViewContacts;
  final ContactState? state;
  final Future<void> Function()? onSendRequest;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onReject;
  final bool showRequestActions;

  const CardDetailsScreen({
    super.key,
    required this.card,
    required this.canViewContacts,
    this.state,
    this.onSendRequest,
    this.onAccept,
    this.onReject,
    this.showRequestActions = false,
  });

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late ContactState currentState;

  /// Перевірка чи належить візитка поточному авторизованому користувачу
  bool get isMyCard {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && currentUserId == widget.card.ownerId;
  }

  @override
  void initState() {
    super.initState();
    currentState = widget.state ?? ContactState.none;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Color(widget.card.cardColor);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: const Color(0xfff8fafc),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Візитка",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(cardColor),
            const SizedBox(height: 20),
            _buildAbout(cardColor),
            const SizedBox(height: 20),
            // Власник картки завжди бачить свої контакти
            if (widget.canViewContacts || isMyCard)
              _buildContacts(cardColor)
            else
              _buildLockedContacts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: widget.card.photoUrl.isNotEmpty
                      ? Image.network(
                    widget.card.photoUrl,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.card.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.card.position,
                      style: TextStyle(
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.card.company,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Для власної картки кнопки запиту не відображаємо
          if (!isMyCard) ...[
            const SizedBox(height: 20),
            if (widget.showRequestActions)
              _buildNotificationButtons(color)
            else if (currentState != ContactState.connected)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: _buildBottomButton(color),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationButtons(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              if (widget.onReject != null) {
                await widget.onReject!();
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Відхилити"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (widget.onAccept != null) {
                await widget.onAccept!();
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Підтвердити"),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color color) {
    switch (currentState) {
      case ContactState.none:
        return ElevatedButton(
          onPressed: () async {
            if (widget.onSendRequest == null) return;

            await widget.onSendRequest!();

            if (!mounted) return;

            setState(() {
              currentState = ContactState.pendingOutgoing;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: const Text("Надіслати запит"),
        );

      case ContactState.pendingOutgoing:
        return const ElevatedButton(
          onPressed: null,
          child: Text("Запит надіслано"),
        );

      case ContactState.pendingIncoming:
        return const ElevatedButton(
          onPressed: null,
          child: Text("Вхідний запит"),
        );

      case ContactState.connected:
        return const SizedBox();
    }
  }

  Widget _buildAbout(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Про себе",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.card.about.isEmpty
                ? "Користувач не додав опис."
                : widget.card.about,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContacts(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Контакти",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          _contact(Icons.phone, widget.card.phone),
          _contact(Icons.email, widget.card.email),
          _contact(Icons.language, widget.card.website),
          _contact(Icons.send, widget.card.telegram),
          _contact(Icons.business, widget.card.linkedin),
          _contact(Icons.code, widget.card.github),
          _contact(Icons.camera_alt, widget.card.instagram),
        ],
      ),
    );
  }

  Widget _buildLockedContacts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 44,
          ),
          SizedBox(height: 12),
          Text(
            "Контактна інформація прихована",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Додайте користувача до контактів,\nщоб побачити телефон, email та соціальні мережі.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _contact(
      IconData icon,
      String text,
      ) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          if (icon == Icons.phone) {
            await _launchPhone(text);
          } else if (icon == Icons.email) {
            await _launchEmail(text);
          } else {
            await _launchUrl(text);
          }
        },
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    var value = url.trim();

    if (value.isEmpty) return;

    if (value.startsWith('@')) {
      value = 'https://t.me/${value.substring(1)}';
    }

    Uri? uri = Uri.tryParse(value);

    if (uri == null) return;

    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$value');
    }

    if (uri == null) return;

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint('Не вдалося відкрити: $value');
    }
  }
}