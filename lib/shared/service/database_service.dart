import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:logger/logger.dart';

import '../model/product_model.dart';
import '../model/user_model.dart';
import '../utils/logger_util.dart';

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

  Future<void> initialize() async {
    try {
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
        logs('User with uid $uid not found. Recreating user document.',
            level: Level.warning);
        // Retrieve current Firebase Auth user details
        final fbUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (fbUser == null) {
          logs(
              'Firebase Auth user not found. Cannot recreate Firestore document.',
              level: Level.error);
          return null;
        }
        // Leverage the displayName, or default to 'unknown'
        final fullName = fbUser.displayName?.toLowerCase().trim() ?? 'unknown';
        // Customize shop owner flag as needed; using false as default here.
        final bool isShopOwner = false;
        final User newUser = User(
          fullName: fullName,
          isShopOwner: isShopOwner,
          imageBase64: null,
          createdAt: DateTime.now(),
          description: null,
        );
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        logs('User with uid $uid re-created successfully.', level: Level.info);
        return newUser;
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

      // Enforce that the product has at least one image.
      if (product.imagesBase64 == null || product.imagesBase64!.isEmpty) {
        throw DatabaseException('Product must have at least one image');
      }

      final owner = await getUser(product.ownerUid);
      if (owner == null || !owner.isShopOwner) {
        throw DatabaseException('User is not authorized to add products');
      }

      final docRef =
          await _firestore.collection('products').add(product.toMap());
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

      // Enforce that the updated product has at least one image.
      if (updatedProduct.imagesBase64 == null ||
          updatedProduct.imagesBase64!.isEmpty) {
        throw DatabaseException('Product must have at least one image');
      }

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw DatabaseException('Product not found');
      }

      final existingProduct = Product.fromFirestore(doc);
      if (existingProduct.ownerUid != updatedProduct.ownerUid) {
        throw DatabaseException('User is not the owner of this product');
      }

      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedProduct.toMap());
    } catch (e) {
      logs('Error updating product: $e', level: Level.error);
      throw DatabaseException('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String productId, String ownerUid) async {
    try {
      await initialize();
      logs('Attempting to delete product $productId for owner $ownerUid',
          level: Level.debug);

      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        logs('Product not found', level: Level.warning);
        throw DatabaseException('Product not found');
      }

      final product = Product.fromFirestore(doc);
      if (product.ownerUid != ownerUid) {
        logs('Ownership mismatch', level: Level.warning);
        throw DatabaseException(
            'User is not authorized to delete this product');
      }

      await _firestore.collection('products').doc(productId).delete();
      logs('Product deleted successfully', level: Level.info);
    } on FirebaseException catch (e) {
      logs('Firestore error deleting product: ${e.code} - ${e.message}',
          level: Level.error);
      throw DatabaseException('Failed to delete product: ${e.message}');
    } catch (e) {
      logs('Unexpected error deleting product: $e', level: Level.error);
      throw DatabaseException('Failed to delete product');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      await initialize();
      final querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      logs('Error retrieving products: $e', level: Level.error);
      throw DatabaseException('Error retrieving products: $e');
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      await initialize();
      final doc = await _firestore.collection('products').doc(productId).get();
      return doc.exists ? Product.fromFirestore(doc) : null;
    } catch (e) {
      logs('Error getting product: $e', level: Level.error);
      throw DatabaseException('Error getting product: $e');
    }
  }
}
