import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

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

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _messaging.requestPermission(
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
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    try {
      await saveTokenForCurrentUser();
    } catch (_) {}

    const channel = AndroidNotificationChannel(
      'cardswap_notifications',
      'CardSwap Notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((message) async {

      final type = message.data["type"];

      switch (type) {
        case "exchange_success":
          _notifyExchangeSuccess();
          return;

        case "request":
        case "request_accepted":
        case "request_declined":
          _notifyNotificationsChanged();
          break;
      }

      final notification = message.notification;

      if (notification == null) return;

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cardswap_notifications',
            'CardSwap Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );

    });

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (_) async {
        await saveTokenForCurrentUser();
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((message) {

      final type = message.data["type"];

      switch (type) {
        case "exchange_success":
          _notifyExchangeSuccess();
          break;

        case "request":
        case "request_accepted":
        case "request_declined":
          _notifyNotificationsChanged();
          break;
      }

    });
  }

  Future saveTokenForCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final token = await _messaging.getToken();

      if (token == null) return;

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
      print("FCM token error: $e");
    }
  }

  Future<void> deleteCurrentToken() async {
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
  }
}