class UserProfileModel {
  final String id;
  final String displayName;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String photoUrl;

  UserProfileModel({
    required this.id,
    required this.displayName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.position,
    required this.photoUrl,
  });

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? id,
      displayName: map['displayName'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      position: map['position'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
}