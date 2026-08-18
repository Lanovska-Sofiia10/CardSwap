import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../repositories/notification_repository.dart';
import '../../models/contact_request_model.dart';
import '../../widgets/card_details_screen.dart';
import '../../widgets/notification_request_card_widget.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final NotificationRepository repository =
  NotificationRepository();

  bool _requestsMarkedAsRead = false;

  Future<List<ContactRequestModel>>? _requestsFuture;

  @override
  void initState() {
    super.initState();

    _requestsFuture = repository.getRequests();

    NotificationService.instance.addNotificationListener(
      _onNotificationReceived,
    );
  }

  void _onNotificationReceived() {
    if (!mounted) return;

    setState(() {
      _requestsMarkedAsRead = false;
      _requestsFuture = repository.getRequests();
    });
  }

  @override
  void dispose() {
    NotificationService.instance.removeNotificationListener(
      _onNotificationReceived,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = repository.currentUserId;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Користувач не авторизований",
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),

        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // <-- додай
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
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

      body: Column(
          children: [


            Expanded(
              child: FutureBuilder<List<ContactRequestModel>>(
                future: _requestsFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  final requests = snapshot.data ?? [];

                  if (!_requestsMarkedAsRead && requests.isNotEmpty) {
                    _requestsMarkedAsRead = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      repository.markAllAsRead(
                        requests.map((e) => e.id).toList(),
                      );
                    });
                  }

                  if (requests.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.notifications_none_rounded,
                              size: 80,
                              color:
                              Colors.grey.shade400,
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              "У вас поки немає сповіщень",
                              textAlign:
                              TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Нові запити на контакти\nз'являться тут",
                              textAlign:
                              TextAlign.center,
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
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      30,
                    ),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 18),
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
                                  await repository.acceptRequest(request);

                                  if (!mounted) return;

                                  setState(() {
                                    _requestsFuture = repository.getRequests();
                                  });

                                  Navigator.pop(context);
                                },

                                onReject: () async {
                                  await repository.rejectRequest(request);

                                  if (!mounted) return;

                                  setState(() {
                                    _requestsFuture = repository.getRequests();
                                  });

                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },

                        onAccept: () async {
                          await repository.acceptRequest(request);

                          if (!mounted) return;

                          setState(() {
                            _requestsFuture = repository.getRequests();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Контакт успішно додано"),
                            ),
                          );
                        },

                        onReject: () async {
                          await repository.rejectRequest(request);

                          if (!mounted) return;

                          setState(() {
                            _requestsFuture = repository.getRequests();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Запит відхилено"),
                            ),
                          );
                        },
                      );                    },
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}