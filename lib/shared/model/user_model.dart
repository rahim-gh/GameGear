import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String fullName;
  final bool isShopOwner;
  final String? imageBase64;
  final DateTime createdAt;
  final String? description; // shop owner

  User({
    required this.fullName,
    this.isShopOwner = false,
    this.imageBase64,
    required this.createdAt,
    this.description,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      fullName: data['fullName'] ?? 'Unknown',
      isShopOwner: data['isShopOwner'] ?? false,
      imageBase64: data['imageBase64'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'isShopOwner': isShopOwner,
      'imageBase64': imageBase64,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
    };
  }

  @override
  String toString() {
    return 'User{fullName: $fullName, isShopOwner: $isShopOwner, imageBase64: $imageBase64, createdAt: $createdAt, description: $description}';
  }
}
