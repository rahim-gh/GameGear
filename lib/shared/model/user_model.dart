class User {
  final String fullName;
  final bool isShopOwner;
  final String? imageBase64;

  User({
    required this.fullName,
    this.isShopOwner = false,
    this.imageBase64,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      fullName: data['fullName'] ?? 'Unknown',
      isShopOwner: data['isShopOwner'] ?? false,
      imageBase64: data['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'isShopOwner': isShopOwner,
      'imageBase64': imageBase64,
    };
  }

  @override
  String toString() {
    return 'User{fullName: $fullName, isShopOwner: $isShopOwner, imageBase64: $imageBase64}';
  }
}
