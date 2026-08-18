class UserProfileModel {
  final String id;

  final String email;
  final String displayName;
  final String photoUrl;

  final String fullName;
  final String phone;
  final String position;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.fullName,
    required this.phone,
    required this.position,
  });
}