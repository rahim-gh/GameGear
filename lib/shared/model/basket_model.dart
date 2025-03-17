// basket_model.dart
import 'package:flutter/material.dart';

import '../model/product_model.dart';

class BasketModel extends ChangeNotifier {
  final Map<Product, int> _products = {};

  Map<Product, int> get products => _products;

  void addProduct(Product product, {int quantity = 1}) {
    if (_products.containsKey(product)) {
      _products[product] = _products[product]! + quantity;
    } else {
      _products[product] = quantity;
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    if (_products.containsKey(product)) {
      _products.remove(product);

      notifyListeners();
    }
  }

  double get totalPrice {
    return _products.entries
        .fold(0, (sum, entry) => sum + (entry.key.price * entry.value));
  }
}
