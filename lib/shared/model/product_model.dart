class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final String? imageBase64;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.tags = const [],
    this.imageBase64,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      imageBase64: data['imageBase64'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'tags': tags,
      'imageBase64': imageBase64,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, tags: $tags, imageBase64: $imageBase64}';
  }
}
