import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  // Легкий клієнт Dio з коротким таймаутом
  final Dio _checkDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Stream<bool> get onConnectivityChanged => _controller.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen((_) async {
      final hasNet = await checkConnection();
      _controller.add(hasNet);
    });
  }

  /// Надійна перевірка реального доступу до мережі
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();

    // Якщо система чітко каже, що немає жодної мережі (ані Wi-Fi, ані Mobile)
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      // Робимо швидкий HEAD запит на генератор 204 відповіді від Google
      final response = await _checkDio.head('https://clients3.google.com/generate_204');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      // Якщо Google недоступний, пробуємо запасний надедійний сервер (Cloudflare)
      try {
        final fallbackResponse = await _checkDio.head('https://1.1.1.1');
        return fallbackResponse.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }
}