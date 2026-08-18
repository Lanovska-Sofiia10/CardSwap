import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/backend_service.dart';

class ScanQrRepository {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BackendService.baseUrl,
    ),
  );

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> exchangeCards({
    required String scannedCardId,
    required String myCardId,
  }) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Користувач не авторизований");
    }

    final token = await user.getIdToken();

    final response = await _dio.post(
      "/exchange/qr",
      data: {
        "myCardId": myCardId,
        "targetCardId": scannedCardId,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    debugPrint(response.data.toString());
  }
}