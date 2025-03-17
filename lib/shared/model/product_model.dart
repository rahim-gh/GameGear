import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final List<String>? imagesBase64; // Multiple images support
  final String ownerUid;
  final DateTime createdAt;
  final double rate;

  Product({
    required this.name,
    required this.description,
    required this.price,
    this.tags = const [],
    this.imagesBase64,
    required this.ownerUid,
    required this.createdAt,
    this.rate = 0.0,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      imagesBase64: data['imagesBase64'] != null
          ? List<String>.from(data['imagesBase64'])
          : null,
      ownerUid: data['ownerUid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      rate: (data['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'tags': tags,
      'imagesBase64': imagesBase64,
      'ownerUid': ownerUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'rate': rate,
    };
  }

  @override
  String toString() {
    return 'Product{name: $name, description: $description, price: $price, tags: $tags, imagesBase64: $imagesBase64, ownerUid: $ownerUid, createdAt: $createdAt, rate: $rate}';
  }
}
