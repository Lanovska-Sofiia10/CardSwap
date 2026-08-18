import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return UserModel(
      id: id,
      email: map["email"] ?? "",
      displayName: map["displayName"] ?? "",
      photoUrl: map["photoUrl"] ?? "",
      createdAt:
      (map["createdAt"] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}