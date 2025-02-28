import 'package:game_gear/shared/model/product/product_model.dart';
import 'package:game_gear/shared/model/user/user_model.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

/// Custom exception for database-related errors.
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => "DatabaseException: $message";
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Box<User>? _userBox;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Initializes the Hive box for users if not already open.
  Future<void> initialize() async {
    try {
      if (_userBox != null && _userBox!.isOpen) return;

      if (Hive.isBoxOpen('userBox')) {
        _userBox = Hive.box<User>('userBox');
      } else {
        _userBox = await Hive.openBox<User>('userBox');
      }
      applog('Hive box "userBox" opened successfully.', level: Level.info);
    } catch (e) {
      applog('Error opening Hive box "userBox": $e', level: Level.error);
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  /// Adds a new user to the database.
  /// Returns null if a user with the same email already exists.
  Future<int?> addUser(
    String fullname,
    String email,
    String password, {
    bool isShopOwner = false,
  }) async {
    try {
      fullname = fullname.toLowerCase().trim();
      email = email.toLowerCase().trim();
      password = password.trim();

      await initialize();
      if (_userBox!.values.any((user) => user.email == email)) {
        applog('User with email $email already exists.', level: Level.warning);
        return null;
      }
      final int id = _userBox!.length;
      final user = User(
        id: id,
        fullname: fullname,
        email: email,
        password: password,
        isShopOwner: isShopOwner,
      );
      await _userBox!.add(user);
      applog('User with email $email added successfully.', level: Level.info);

      // If the user is a shop owner, create a dedicated Hive box for products.
      if (isShopOwner) {
        await Hive.openBox<Product>('products_$id');
        applog('Product box for shop owner with id $id created.',
            level: Level.info);
      }
      return id;
    } catch (e) {
      applog('Error adding user with email $email: $e', level: Level.error);
      throw DatabaseException('Error adding user: $e');
    }
  }

  /// Retrieves a user by ID.
  Future<User?> getUser(int id) async {
    try {
      await initialize();
      final user = _userBox!.get(id);
      if (user != null) {
        applog('User with id $id retrieved successfully.', level: Level.info);
      } else {
        applog('User with id $id not found.', level: Level.warning);
      }
      return user;
    } catch (e) {
      applog('Error retrieving user with id $id: $e', level: Level.error);
      throw DatabaseException('Error retrieving user: $e');
    }
  }

  /// Updates the user with the given ID.
  Future<void> updateUser(
      int id, String fullname, String email, String password) async {
    try {
      fullname = fullname.toLowerCase().trim();
      email = email.toLowerCase().trim();
      password = password.trim();

      await initialize();
      final user = User(
        id: id,
        fullname: fullname,
        email: email,
        password: password,
      );
      await _userBox!.put(id, user);
      applog('User with id $id updated successfully.', level: Level.info);
    } catch (e) {
      applog('Error updating user with id $id: $e', level: Level.error);
      throw DatabaseException('Error updating user: $e');
    }
  }

  /// Deletes the user with the given ID.
  Future<void> deleteUser(int id) async {
    try {
      await initialize();
      await _userBox!.delete(id);
      applog('User with id $id deleted successfully.', level: Level.info);
    } catch (e) {
      applog('Error deleting user with id $id: $e', level: Level.error);
      throw DatabaseException('Error deleting user: $e');
    }
  }

  /// Retrieves all users from the database.
  Future<List<User>> getAllUsers() async {
    try {
      await initialize();
      final users = _userBox!.values.toList();
      applog('Retrieved ${users.length} users.', level: Level.info);
      return users;
    } catch (e) {
      applog('Error retrieving all users: $e', level: Level.error);
      throw DatabaseException('Error retrieving all users: $e');
    }
  }

  /// Opens (or creates) the product box for a specific shop owner.
  Future<Box<Product>> _openProductBox(int shopOwnerId) async {
    try {
      final String boxName = 'products_$shopOwnerId';
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<Product>(boxName);
      } else {
        return await Hive.openBox<Product>(boxName);
      }
    } catch (e) {
      applog('Error opening product box for shop owner $shopOwnerId: $e',
          level: Level.error);
      throw DatabaseException('Failed to open product box: $e');
    }
  }

  /// Adds a product for a shop owner.
  /// Returns the product ID.
  Future<int> addProductForShopOwner(int shopOwnerId, Product product) async {
    try {
      final box = await _openProductBox(shopOwnerId);
      final int productId = box.length;
      final newProduct = Product(
        id: productId,
        name: product.name,
        description: product.description,
        price: product.price,
        tags: product.tags, // Uses the new tags field
      );
      await box.add(newProduct);
      applog(
          'Product added successfully for shop owner $shopOwnerId with product id: $productId',
          level: Level.info);
      return productId;
    } catch (e) {
      applog('Error adding product for shop owner $shopOwnerId: $e',
          level: Level.error);
      throw DatabaseException('Error adding product: $e');
    }
  }

  /// Retrieves all products for a given shop owner.
  Future<List<Product>> getProductsForShopOwner(int shopOwnerId) async {
    try {
      final box = await _openProductBox(shopOwnerId);
      final products = box.values.toList();
      applog(
          'Retrieved ${products.length} products for shop owner $shopOwnerId',
          level: Level.info);
      return products;
    } catch (e) {
      applog('Error retrieving products for shop owner $shopOwnerId: $e',
          level: Level.error);
      throw DatabaseException('Error retrieving products: $e');
    }
  }
}
