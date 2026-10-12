import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class NetworkAwarenessWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwarenessWidget({super.key, required this.child});

  @override
  State<NetworkAwarenessWidget> createState() => _NetworkAwarenessWidgetState();
}

class _NetworkAwarenessWidgetState extends State<NetworkAwarenessWidget> {
  late StreamSubscription<bool> _subscription;
  bool _isConnected = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();

    _subscription = ConnectivityService.instance.onConnectivityChanged.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final connected = await ConnectivityService.instance.checkConnection();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<void> _manualCheck() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final connected = await ConnectivityService.instance.checkConnection();

    if (mounted) {
      setState(() {
        _isConnected = connected;
        _isChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основний контент додатка (зберігає стан)
        widget.child,

        // Модальне вікно поверх усього екрана, якщо немає інтернету
        if (!_isConnected)
          PopScope(
            canPop: false, // Блокує кнопку "Назад" на Android
            child: Container(
              color: Colors.black54, // Затемнення фону
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xFFEF4444),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Мережа відсутня",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Перевірте підключення до інтернету та спробуйте знову.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isChecking ? null : _manualCheck,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isChecking
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Повторити",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}