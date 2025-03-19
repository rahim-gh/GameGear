// basket_model.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../model/product_model.dart';
import '../utils/logger_util.dart';

class BasketModel extends ChangeNotifier {
  final Map<Product, int> _products = {};

  Map<Product, int> get products => _products;

  /// Adds a product to the basket with a default or specified quantity.
  void addProduct(Product product, {int quantity = 1}) {
    try {
      if (quantity < 1) {
        logs(
            "Invalid quantity ($quantity) provided for product: ${product.name}. Operation aborted.",
            level: Level.warning);
        return;
      }
      logs("Adding product: ${product.name} with quantity: $quantity",
          level: Level.info);

      if (_products.containsKey(product)) {
        _products[product] = _products[product]! + quantity;
      } else {
        _products[product] = quantity;
      }

      notifyListeners();
      logs(
          "Product ${product.name} added successfully. Current quantity: ${_products[product]}",
          level: Level.debug);
    } catch (error, stackTrace) {
      logs(
          "Error in addProduct for ${product.name}: $error, stackTrace: $stackTrace",
          level: Level.error);
    }
  }

  /// Removes a specified quantity of a product from the basket.
  /// If removal quantity is equal or exceeds the current quantity, the product is removed entirely.
  void removeProductQuantity(Product product, int quantityToRemove) {
    try {
      if (!_products.containsKey(product)) {
        logs("Product ${product.name} not found in basket.",
            level: Level.warning);
        return;
      }
      final currentQty = _products[product]!;
      if (quantityToRemove >= currentQty) {
        _products.remove(product);
        logs("Removed all of product ${product.name} from basket.",
            level: Level.info);
      } else {
        _products[product] = currentQty - quantityToRemove;
        logs(
            "Subtracted $quantityToRemove from product ${product.name}. New quantity: ${_products[product]}",
            level: Level.info);
      }
      notifyListeners();
    } catch (error, stackTrace) {
      logs(
          "Error subtracting quantity for ${product.name}: $error, stackTrace: $stackTrace",
          level: Level.error);
    }
  }

  /// Removes a product entirely from the basket.
  void removeProduct(Product product) {
    try {
      if (_products.containsKey(product)) {
        logs("Removing product: ${product.name}", level: Level.info);
        _products.remove(product);
        notifyListeners();
        logs("Product ${product.name} removed successfully.",
            level: Level.debug);
      } else {
        logs("Attempted to remove product not in basket: ${product.name}",
            level: Level.warning);
      }
    } catch (error, stackTrace) {
      logs(
          "Error in removeProduct for ${product.name}: $error, stackTrace: $stackTrace",
          level: Level.error);
    }
  }

  /// Calculates the total price of the products in the basket.
  double get totalPrice {
    try {
      double total = _products.entries
          .fold(0, (sum, entry) => sum + (entry.key.price * entry.value));
      logs("Total price calculated: \$${total.toStringAsFixed(2)}",
          level: Level.debug);
      return total;
    } catch (error, stackTrace) {
      logs("Error calculating totalPrice: $error, stackTrace: $stackTrace",
          level: Level.error);
      return 0;
    }
  }
}
