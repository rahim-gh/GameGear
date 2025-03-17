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
  @override
  Widget build(BuildContext context) {
    final basketModel = Provider.of<BasketModel>(context);

    return Scaffold(
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
                  child: Text('Buy'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: basketModel.products.length,
              itemBuilder: (context, index) {
                final product = basketModel.products.keys.elementAt(index);
                final quantity = basketModel.products[product];
                return BasketProductWidget(
                  product: product,
                  quantity: quantity!,
                  onRemove: () {
                    basketModel.removeProduct(product);
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
