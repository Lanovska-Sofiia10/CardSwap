class CardModel {
  final String id;

  final String fullName;
  final String position;
  final String company;

  final String phone;
  final String email;
  final String website;

  final String linkedin;
  final String telegram;
  final String instagram;
  final String github;

  final String photoUrl;
  final String about;
  final int cardColor;

  final String ownerId;
  final bool showInCatalog;

  CardModel({
    required this.id,

    required this.fullName,
    required this.position,
    required this.company,

    required this.phone,
    required this.email,
    required this.website,

    required this.linkedin,
    required this.telegram,
    required this.instagram,
    required this.github,

    required this.photoUrl,
    required this.about,
    required this.cardColor,

    required this.ownerId,
    required this.showInCatalog,
  });

  factory CardModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    return CardModel(
      id: id,

      fullName: json['fullName'] ?? '',
      position: json['position'] ?? '',
      company: json['company'] ?? '',

      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',

      linkedin: json['linkedin'] ?? '',
      telegram: json['telegram'] ?? '',
      instagram: json['instagram'] ?? '',
      github: json['github'] ?? '',

      photoUrl: json['photoUrl'] ?? '',
      about: json['about'] ?? '',

      cardColor: json['cardColor'] is int
          ? json['cardColor']
          : int.tryParse(json['cardColor'].toString()) ?? 0xFFF59E0B,

      ownerId: json['ownerId'] ?? '',
      showInCatalog: json['showInCatalog'] is bool
          ? json['showInCatalog']
          : json['showInCatalog'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,

      'fullName': fullName,
      'position': position,
      'company': company,

      'phone': phone,
      'email': email,
      'website': website,

      'linkedin': linkedin,
      'telegram': telegram,
      'instagram': instagram,
      'github': github,

      'photoUrl': photoUrl,
      'about': about,

      'cardColor': cardColor,
      'showInCatalog': showInCatalog,
    };
  }
}