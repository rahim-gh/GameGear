import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.tags = const [],
  });

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, tags: $tags}';
  }
}
