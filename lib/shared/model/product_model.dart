import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  late final String id;
  late final String name;
  late final String description;
  late final double price;
  late final List<String> tags;
  late final List<String>? imagesBase64; // Multiple images support
  late final String ownerUid;
  late final DateTime createdAt;
  late final double rate;
  late final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.tags = const [],
    this.imagesBase64,
    required this.ownerUid,
    required this.createdAt,
    this.rate = 0.0,
    required this.quantity,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
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
      quantity: data['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'tags': tags,
      'imagesBase64': imagesBase64,
      'ownerUid': ownerUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'rate': rate,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, tags: $tags, imagesBase64: $imagesBase64, ownerUid: $ownerUid, createdAt: $createdAt, rate: $rate, quantity: $quantity}';
  }
}
