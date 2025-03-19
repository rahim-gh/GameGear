// basket_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart';
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/basket_product_widget.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  /// Prompts the user for the quantity to remove.
  Future<int?> _askQuantityToRemove(
      BuildContext context, int currentQuantity) async {
    final TextEditingController removalController = TextEditingController();
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Product"),
          content: TextField(
            controller: removalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter quantity to remove (max: $currentQuantity)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final removal = int.tryParse(removalController.text);
                Navigator.of(context).pop(removal);
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final basketModel = Provider.of<BasketModel>(context);
    final productsMap = basketModel.products;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: "Basket"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.primaryColor,
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${basketModel.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: AppTheme.accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: AppTheme.buttonStyle,
                  onPressed: () {
                    // Implement buy logic here
                  },
                  child: const Text('Buy'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productsMap.length,
              itemBuilder: (context, index) {
                final product = productsMap.keys.elementAt(index);
                final quantity = productsMap[product] ?? 0;
                if (quantity == 0) return const SizedBox.shrink();

                return BasketProductWidget(
                  product: product,
                  quantity: quantity,
                  onRemove: () async {
                    final removalQuantity =
                        await _askQuantityToRemove(context, quantity);
                    if (removalQuantity != null && removalQuantity > 0) {
                      basketModel.removeProductQuantity(
                          product, removalQuantity);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
