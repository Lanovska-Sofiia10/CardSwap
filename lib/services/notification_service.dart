import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final List<VoidCallback> _exchangeListeners = [];
  final List<VoidCallback> _notificationListeners = [];

  void addExchangeListener(VoidCallback listener) {
    if (!_exchangeListeners.contains(listener)) {
      _exchangeListeners.add(listener);
    }
  }

  void removeExchangeListener(VoidCallback listener) {
    _exchangeListeners.remove(listener);
  }

  void addNotificationListener(VoidCallback listener) {
    if (!_notificationListeners.contains(listener)) {
      _notificationListeners.add(listener);
    }
  }

  void removeNotificationListener(VoidCallback listener) {
    _notificationListeners.remove(listener);
  }

  void _notifyNotificationsChanged() {
    final listeners = List<VoidCallback>.from(_notificationListeners);
    for (final listener in listeners) {
      try {
        listener();
      } catch (_) {}
    }
  }

  void _notifyExchangeSuccess() {
    final listeners = List<VoidCallback>.from(_exchangeListeners);
    for (final listener in listeners) {
      try {
        listener();
      } catch (_) {}
    }
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> _saveTokenWhenReady() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken;

      for (int i = 0; i < 5; i++) {
        apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('APNs token: $apnsToken');
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null) {
        debugPrint('APNs token is not available yet');
        return;
      }
    }

    await saveTokenForCurrentUser();
  }

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        _handleMessageDataPayload(details.payload);
      },
    );

    const channel = AndroidNotificationChannel(
      'cardswap_notifications',
      'CardSwap Notifications',
      description: 'Канал сповіщень додатку CardSwap',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _saveTokenWhenReady();

    FirebaseMessaging.onMessage.listen((message) async {
      _processMessageData(message.data);

      final notification = message.notification;

      if (notification != null && defaultTargetPlatform == TargetPlatform.android) {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data['type'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _processMessageData(message.data);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _processMessageData(initialMessage.data);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
      await saveTokenForCurrentUser();
    });
  }

  void _processMessageData(Map<String, dynamic> data) {
    final type = data["type"];
    switch (type) {
      case "exchange_success":
        _notifyExchangeSuccess();
        break;
      case "request":
      case "request_accepted":
      case "request_declined":
      case "exchange_request_received":
        _notifyNotificationsChanged();
        break;
    }
  }

  void _handleMessageDataPayload(String? payload) {
    if (payload == null) return;
    _processMessageData({"type": payload});
  }

  Future<void> saveTokenForCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNs token is not available yet');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('FCM token is null');
        return;
      }

      debugPrint('FCM token saved: $token');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': token,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  Future<void> deleteCurrentToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Delete token error: $e');
    }
  }
}