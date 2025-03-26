// product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Matches Firestore document ID
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final List<String>? imagesBase64;
  final String ownerUid;
  final DateTime createdAt;
  final double rate;
  final int quantity;

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

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      imagesBase64: data['imagesBase64'] != null
          ? List<String>.from(data['imagesBase64'])
          : null,
      ownerUid: data['ownerUid'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      rate: (data['rate'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
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
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, tags: $tags, imagesBase64: $imagesBase64, ownerUid: $ownerUid, createdAt: $createdAt, rate: $rate, quantity: $quantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
