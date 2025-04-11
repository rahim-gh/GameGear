// basket_model.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../model/product_model.dart';
import '../utils/logger_util.dart';

class BasketModel extends ChangeNotifier {
  final Map<Product, int> _products = {};

  Map<Product, int> get products => Map.unmodifiable(_products);

  void addProduct(Product product, {int quantity = 1}) {
    try {
      if (quantity < 1) {
        logs("Invalid quantity ($quantity) for ${product.name}",
            level: Level.warning);
        return;
      }

      _products.update(
        product,
        (value) => (product.quantity >= value + quantity) ? value + quantity : value,
        ifAbsent: () => quantity,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      logs("Add product error: $error",
          level: Level.error, stackTrace: stackTrace);
    }
  }

  void removeProductQuantity(Product product, int quantityToRemove) {
    try {
      final currentQty = _products[product] ?? 0;
      if (currentQty <= quantityToRemove) {
        _products.remove(product);
      } else {
        _products[product] = currentQty - quantityToRemove;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      logs("Remove quantity error: $error",
          level: Level.error, stackTrace: stackTrace);
    }
  }

  void removeProduct(Product product) {
    if (_products.containsKey(product)) {
      _products.remove(product);
      notifyListeners();
    }
  }

  void clearBasket() {
    _products.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _products.entries.fold(
      0,
      (total, entry) => total + (entry.key.price * entry.value),
    );
  }
}
