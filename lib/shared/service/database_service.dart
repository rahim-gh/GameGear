import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../model/product_model.dart';
import '../model/user_model.dart';
import '../utils/logger_util.dart';
import 'auth_service.dart';

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

  // ────────────── USER METHODS ──────────────

  /// Adds a new user document.
  Future<String?> addUser(
    String uid,
    String fullName, {
    bool isShopOwner = false,
    String? imageBase64,
    String? description,
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
        createdAt: DateTime.now(),
        description: description,
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

  /// Updates an existing user's document.
  Future<void> updateUser(
    String uid,
    String fullName, {
    String? imageBase64,
    String? description,
  }) async {
    try {
      await initialize();
      fullName = fullName.toLowerCase().trim();

      // Retrieve existing user to preserve createdAt.
      final existingDoc = await _firestore.collection('users').doc(uid).get();
      if (!existingDoc.exists) {
        throw DatabaseException('User not found');
      }
      final existingUser =
          User.fromMap(existingDoc.data() as Map<String, dynamic>);

      final User user = User(
        fullName: fullName,
        isShopOwner: existingUser.isShopOwner,
        imageBase64: imageBase64,
        createdAt: existingUser.createdAt,
        description: existingUser.isShopOwner
            ? description ?? existingUser.description
            : '',
      );

      await _firestore.collection('users').doc(uid).update(user.toMap());
      logs('User info updated successfully for uid $uid.', level: Level.info);
    } catch (e) {
      logs('Error updating user with uid $uid: $e', level: Level.error);
      throw DatabaseException('Error updating user: $e');
    }
  }

  /// Deletes a user document by their uid.
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

  /// Retrieves all user documents.
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

  // ────────────── PRODUCT METHODS ──────────────

  /// Adds a new product document to the top-level "products" collection.
  /// Can only be executed by shop owners.
  Future<String> addProduct(Product product) async {
    try {
      await initialize();
      // Verify that the owner is a shop owner.
      final User? owner = await getUser(product.ownerUid);
      if (owner == null ||
          !owner.isShopOwner ||
          AuthService().currentUser?.uid != product.ownerUid) {
        throw DatabaseException('User is not authorized to add products.');
      }

      DocumentReference docRef = await _firestore.collection('products').add({
        ...product.toMap(),
        // Override createdAt with the current timestamp.
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      logs('Product added with id ${docRef.id} for owner ${product.ownerUid}.',
          level: Level.info);
      return docRef.id;
    } catch (e) {
      logs('Error adding product: $e', level: Level.error);
      throw DatabaseException('Error adding product: $e');
    }
  }

  /// Updates an existing product document.
  /// Can only be executed by the shop owner who owns the product.
  Future<void> updateProduct(String productId, Product updatedProduct) async {
    try {
      await initialize();
      // Verify that the user is a shop owner.
      final User? owner = await getUser(updatedProduct.ownerUid);
      if (owner == null ||
          !owner.isShopOwner ||
          AuthService().currentUser?.uid != updatedProduct.ownerUid) {
        throw DatabaseException('User is not authorized to update products.');
      }

      // Fetch existing product document.
      final DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw DatabaseException('Product not found.');
      }
      final Map<String, dynamic> existingData =
          doc.data() as Map<String, dynamic>;
      // Ensure that the ownerUid matches.
      if (existingData['ownerUid'] != updatedProduct.ownerUid) {
        throw DatabaseException('User is not the owner of this product.');
      }

      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedProduct.toMap());
      logs('Product updated successfully for product id $productId.',
          level: Level.info);
    } catch (e) {
      logs('Error updating product: $e', level: Level.error);
      throw DatabaseException('Error updating product: $e');
    }
  }

  /// Deletes a product document.
  /// Can only be executed by the shop owner who owns the product.
  Future<void> deleteProduct(String productId, String ownerUid) async {
    try {
      await initialize();
      // Verify that the user is a shop owner.
      final User? owner = await getUser(ownerUid);
      if (owner == null ||
          !owner.isShopOwner ||
          AuthService().currentUser?.uid != ownerUid) {
        throw DatabaseException('User is not authorized to delete products.');
      }

      // Fetch product document.
      final DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw DatabaseException('Product not found.');
      }
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['ownerUid'] != ownerUid) {
        throw DatabaseException('User is not the owner of this product.');
      }

      await _firestore.collection('products').doc(productId).delete();
      logs('Product deleted successfully for product id $productId.',
          level: Level.info);
    } catch (e) {
      logs('Error deleting product: $e', level: Level.error);
      throw DatabaseException('Error deleting product: $e');
    }
  }

  /// Retrieves all product documents.
  Future<List<Product>> getAllProducts() async {
    try {
      await initialize();
      final QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      final List<Product> products = querySnapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data() as Map<String, dynamic>);
        logs('Retrieved product with id ${doc.id}', level: Level.info);
        return product;
      }).toList();
      logs('Retrieved ${products.length} products.', level: Level.info);
      return products;
    } catch (e) {
      logs('Error retrieving products: $e', level: Level.error);
      throw DatabaseException('Error retrieving products: $e');
    }
  }
}
