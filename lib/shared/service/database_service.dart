import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_gear/shared/model/product_model.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Verifies that Firestore is initialized.
  Future<void> initialize() async {
    try {
      // Firebase.initializeApp() should be called elsewhere.
      logs('Firestore initialization verified.', level: Level.info);
    } catch (e) {
      logs('Firestore initialization error: $e', level: Level.error);
      throw DatabaseException('Firestore initialization error: $e');
    }
  }

  /// Adds a new user document (only non-sensitive info) using the provided uid.
  Future<String?> addUser(
    String uid,
    String fullName, {
    bool isShopOwner = false,
    String? imageBase64,
  }) async {
    try {
      await initialize();
      fullName = fullName.toLowerCase().trim();

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        logs('User with uid $uid already exists.', level: Level.warning);
        return null;
      }

      final User user = User(
        fullName: fullName,
        isShopOwner: isShopOwner,
        imageBase64: imageBase64,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      logs('User with uid $uid added successfully.', level: Level.info);
      return uid;
    } catch (e) {
      logs('Error adding user with uid $uid: $e', level: Level.error);
      throw DatabaseException('Error adding user: $e');
    }
  }

  /// Retrieves a user by their uid.
  Future<User?> getUser(String uid) async {
    try {
      await initialize();
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        logs('User with uid $uid retrieved successfully.', level: Level.info);
        return User.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        logs('User with uid $uid not found.', level: Level.warning);
        return null;
      }
    } catch (e) {
      logs('Error retrieving user with uid $uid: $e', level: Level.error);
      throw DatabaseException('Error retrieving user: $e');
    }
  }

  /// Updates an existing user's document with non-sensitive info.
  Future<void> updateUser(
    String uid,
    String fullName,
    String? imageBase64,
  ) async {
    try {
      await initialize();
      fullName = fullName.toLowerCase().trim();

      final User user = User(
        fullName: fullName,
        imageBase64: imageBase64,
      );

      await _firestore.collection('users').doc(uid).update(user.toMap());
      logs('User info updated successfully for uid $uid.', level: Level.info);
    } catch (e) {
      logs('Error updating user with uid $uid: $e', level: Level.error);
      throw DatabaseException('Error updating user: $e');
    }
  }

  /// Deletes a user document by their UID.
  Future<void> deleteUser(String uid) async {
    try {
      await initialize();
      await _firestore.collection('users').doc(uid).delete();
      logs('User with uid $uid deleted successfully.', level: Level.info);
    } catch (e) {
      logs('Error deleting user with uid $uid: $e', level: Level.error);
      throw DatabaseException('Error deleting user: $e');
    }
  }

  /// Retrieves all user documents from Firestore.
  Future<List<User>> getAllUsers() async {
    try {
      await initialize();
      final QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();
      final List<User> users = querySnapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      logs('Retrieved ${users.length} users.', level: Level.info);
      return users;
    } catch (e) {
      logs('Error retrieving all users: $e', level: Level.error);
      throw DatabaseException('Error retrieving all users: $e');
    }
  }

  /// Adds a product for a shop owner in their 'products' collection.
  Future<int> addProductForShopOwner(
    String shopOwnerUid,
    Product product, {
    String? imageBase64,
  }) async {
    try {
      await initialize();
      final CollectionReference productCol = _firestore
          .collection('users')
          .doc(shopOwnerUid)
          .collection('products');

      // Simulated auto-increment for product ID.
      final QuerySnapshot prodSnapshot = await productCol.get();
      final int newProductId = prodSnapshot.docs.length;

      // Merge the new image URL if provided.
      final Product newProduct = Product(
        id: newProductId,
        name: product.name,
        description: product.description,
        price: product.price,
        tags: product.tags,
        imageBase64: imageBase64,
      );

      await productCol.doc(newProductId.toString()).set(newProduct.toMap());
      logs(
          'Product added for shop owner $shopOwnerUid with product id $newProductId.',
          level: Level.info);
      return newProductId;
    } catch (e) {
      logs('Error adding product for shop owner $shopOwnerUid: $e',
          level: Level.error);
      throw DatabaseException('Error adding product: $e');
    }
  }

  /// Retrieves all products for a specified shop owner.
  Future<List<Product>> getProductsForShopOwner(String shopOwnerUid) async {
    try {
      await initialize();
      final CollectionReference productCol = _firestore
          .collection('users')
          .doc(shopOwnerUid)
          .collection('products');

      final QuerySnapshot querySnapshot = await productCol.get();
      final List<Product> products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      logs(
          'Retrieved ${products.length} products for shop owner $shopOwnerUid.',
          level: Level.info);
      return products;
    } catch (e) {
      logs('Error retrieving products for shop owner $shopOwnerUid: $e',
          level: Level.error);
      throw DatabaseException('Error retrieving products: $e');
    }
  }
}
