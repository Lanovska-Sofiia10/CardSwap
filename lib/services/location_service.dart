import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static StreamSubscription<Position>? _positionSubscription;
  static Position? _latestPosition;
  static Position? _bestPosition;
  static bool _isStarted = false;

  // Ціловий поріг точності в метрах (наприклад, відсікаємо все, що гірше 15м)
  static const double targetAccuracyThresholdMeters = 15.0;

  static Position? get latestPosition => _latestPosition;
  static Position? get bestPosition => _bestPosition;

  static Future<void> start() async {
    if (_isStarted) {
      debugPrint('📍 [LocationService] Сервіс геолокації вже запущений.');
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied.");
    }

    final accuracyStatus = await Geolocator.getLocationAccuracy();
    if (accuracyStatus == LocationAccuracyStatus.reduced) {
      throw Exception("Precise location is required.");
    }

    // Платформозалежні налаштування для максимальної точності
    late final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation, // Максимальна точність (GPS + Fused Location)
        distanceFilter: 0,
        forceLocationManager: false, // Використовує Google Play Services Fused Location Provider
        intervalDuration: const Duration(seconds: 1),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    _isStarted = true;
    debugPrint('🚀 [LocationService] Старт стриму геолокації...');

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (Position position) {
        _latestPosition = position;

        final ageInSeconds = DateTime.now().difference(position.timestamp).inSeconds;
        final isRecent = ageInSeconds < 10;

        debugPrint(
          '📡 [STREAM FIX] Lat: ${position.latitude}, Lng: ${position.longitude} | '
              'Точність: ±${position.accuracy.toStringAsFixed(1)}м | '
              'Вік фіксу: ${ageInSeconds}с | Свіжий: $isRecent',
        );

        if (!isRecent) return;

        // Зберігаємо як bestPosition тільки якщо це справді покращення
        if (_bestPosition == null || position.accuracy < _bestPosition!.accuracy) {
          _bestPosition = position;
          debugPrint(
            '⭐ [NEW BEST POSITION] Оновлено найкращу точність: ±${position.accuracy.toStringAsFixed(1)}м',
          );
        }
      },
      onError: (Object error) {
        debugPrint('❌ [LOCATION ERROR]: $error');
      },
    );
  }

  /// Метод для отримання точки під час змаху/натискання кнопки.
  /// Якщо поточна точність недостатня, чекає до [timeout] кращого фіксу.
  static Future<Position?> getAccuratePosition({
    Duration timeout = const Duration(seconds: 3),
    double requiredAccuracy = targetAccuracyThresholdMeters,
  }) async {
    debugPrint('🔍 [getAccuratePosition] Запит координати (Потрібна точність: <= ${requiredAccuracy}м)');

    final best = getBestAvailablePosition();

    // Якщо у нас вже є свіжа точна координата, віддаємо її одразу
    if (best != null && best.accuracy <= requiredAccuracy) {
      final isRecent = DateTime.now().difference(best.timestamp).inSeconds < 5;
      if (isRecent) {
        debugPrint(
          '⚡ [getAccuratePosition] Повертаємо координату з KЕШУ (Точність: ±${best.accuracy.toStringAsFixed(1)}м)',
        );
        return best;
      }
    }

    debugPrint('⏳ [getAccuratePosition] КЕШ застарілий або недостатньо точний. Чекаємо свіжий фікс (таймаут: ${timeout.inSeconds}с)...');

    final completer = Completer<Position?>();
    StreamSubscription<Position>? tempSub;

    tempSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((position) async {
      debugPrint(
        '📥 [TEMP STREAM FIX] Lat: ${position.latitude}, Lng: ${position.longitude} | Точність: ±${position.accuracy.toStringAsFixed(1)}м',
      );

      if (position.accuracy <= requiredAccuracy) {
        if (!completer.isCompleted) {
          debugPrint('✅ [getAccuratePosition] Досягнуто необхідну точність: ±${position.accuracy.toStringAsFixed(1)}м');
          completer.complete(position);
          await tempSub?.cancel();
        }
      }
    });

    // Таймаут fallback — повертаємо найкраще, що встигли зібрати
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        final fallback = getBestAvailablePosition();
        debugPrint(
          '⚠️ [getAccuratePosition] Таймаут! Повертаємо FALLBACK (Точність: ±${fallback?.accuracy.toStringAsFixed(1) ?? "N/A"}м)',
        );
        completer.complete(fallback);
        tempSub?.cancel();
      }
    });

    return completer.future;
  }

  static Position? getBestAvailablePosition() {
    final result = _bestPosition ?? _latestPosition;
    if (result != null) {
      debugPrint(
        '🎯 [getBestAvailablePosition] Lat: ${result.latitude}, Lng: ${result.longitude} | Точність: ±${result.accuracy.toStringAsFixed(1)}м',
      );
    } else {
      debugPrint('⚠️ [getBestAvailablePosition] Немає доступних координат.');
    }
    return result;
  }

  static Future<void> stop() async {
    debugPrint('🛑 [LocationService] Зупинка сервісу геолокації.');
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isStarted = false;
  }

  static void clearPosition() {
    debugPrint('🧹 [LocationService] Очищення збережених координат.');
    _latestPosition = null;
    _bestPosition = null;
  }

  static bool get isStarted => _isStarted;
}