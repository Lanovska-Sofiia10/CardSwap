import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static StreamSubscription<Position>? _positionSubscription;
  static Position? _latestPosition;
  static Position? _bestPosition;
  static bool _isStarted = false;

  static const double targetAccuracyThresholdMeters = 15.0;

  static Position? get latestPosition => _latestPosition;
  static Position? get bestPosition => _bestPosition;

  static Future<void> start() async {
    if (_isStarted) return;

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

    late final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        forceLocationManager: false,
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

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (Position position) {
        _latestPosition = position;

        final ageInSeconds =
            DateTime.now().difference(position.timestamp).inSeconds;
        final isRecent = ageInSeconds < 10;

        if (!isRecent) return;

        if (_bestPosition == null ||
            position.accuracy < _bestPosition!.accuracy) {
          _bestPosition = position;
        }
      },
      onError: (Object error) {},
    );
  }

  static Future<Position?> getAccuratePosition({
    Duration timeout = const Duration(seconds: 3),
    double requiredAccuracy = targetAccuracyThresholdMeters,
  }) async {
    final best = getBestAvailablePosition();

    if (best != null && best.accuracy <= requiredAccuracy) {
      final isRecent = DateTime.now().difference(best.timestamp).inSeconds < 5;
      if (isRecent) {
        return best;
      }
    }

    final completer = Completer<Position?>();
    StreamSubscription<Position>? tempSub;

    tempSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((position) async {
      if (position.accuracy <= requiredAccuracy) {
        if (!completer.isCompleted) {
          completer.complete(position);
          await tempSub?.cancel();
        }
      }
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        final fallback = getBestAvailablePosition();
        completer.complete(fallback);
        tempSub?.cancel();
      }
    });

    return completer.future;
  }

  static Position? getBestAvailablePosition() {
    return _bestPosition ?? _latestPosition;
  }

  static Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isStarted = false;
  }

  static void clearPosition() {
    _latestPosition = null;
    _bestPosition = null;
  }

  static bool get isStarted => _isStarted;
}