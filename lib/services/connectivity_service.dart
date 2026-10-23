import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

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

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final response = await _checkDio.head('https://clients3.google.com/generate_204');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      try {
        final fallbackResponse = await _checkDio.head('https://1.1.1.1');
        return fallbackResponse.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }
}