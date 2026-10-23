import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/contact_request_model.dart';
import '../../repositories/notification_repository.dart';
import '../../services/notification_service.dart';
import '../../widgets/card_details_screen.dart';
import '../../widgets/notification_request_card_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository repository = NotificationRepository();

  bool _requestsMarkedAsRead = false;
  Future<List<ContactRequestModel>>? _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();

    NotificationService.instance.addNotificationListener(_onNotificationReceived);
  }

  void _loadRequests() {
    setState(() {
      _requestsMarkedAsRead = false;
      _requestsFuture = repository.getRequests();
    });
  }

  void _onNotificationReceived() {
    if (!mounted) return;
    _loadRequests();
  }

  @override
  void dispose() {
    NotificationService.instance.removeNotificationListener(_onNotificationReceived);
    super.dispose();
  }

  Future<void> _handleAccept(ContactRequestModel request) async {
    try {
      await repository.acceptRequest(request);
      if (!mounted) return;
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> _handleReject(ContactRequestModel request) async {
    try {
      await repository.rejectRequest(request);
      if (!mounted) return;
      _loadRequests();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
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
    final userId = repository.currentUserId;

    if (userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xfff8fafc),
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text("Сповіщення"),
        ),
        body: const Center(
          child: Text(
            "Користувач не авторизований",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Сповіщення"),
      ),
      body: FutureBuilder<List<ContactRequestModel>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
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
                      snapshot.error.toString().replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadRequests,
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
            );
          }

          final requests = snapshot.data ?? [];

          if (!_requestsMarkedAsRead && requests.isNotEmpty) {
            _requestsMarkedAsRead = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final unreadIds = requests.where((r) => !r.isRead).map((e) => e.id).toList();
              if (unreadIds.isNotEmpty) {
                repository.markAllAsRead(unreadIds);
              }
            });
          }

          if (requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "У вас поки немає сповіщень",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Нові запити на контакти\nз'являться тут",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = requests[index];

              return NotificationRequestCardWidget(
                request: request,
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardDetailsScreen(
                        card: request.card,
                        canViewContacts: false,
                        showRequestActions: true,
                        onAccept: () async {
                          Navigator.pop(context);
                          await _handleAccept(request);
                        },
                        onReject: () async {
                          Navigator.pop(context);
                          await _handleReject(request);
                        },
                      ),
                    ),
                  );
                },
                onAccept: () => _handleAccept(request),
                onReject: () => _handleReject(request),
              );
            },
          );
        },
      ),
    );
  }
}