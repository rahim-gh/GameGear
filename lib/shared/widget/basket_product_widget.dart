// basket_product_widget.dart
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../screen/product/product_screen.dart';
import '../constant/app_theme.dart';
import '../model/product_model.dart';

class BasketProductWidget extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onRemove;

  const BasketProductWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductScreen(product: product);
        }));
      },
      child: Container(
        decoration: AppTheme.cardDecoration,
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                product.name,
                style: AppTheme.titleStyle,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: product.name, // Use product name as a unique tag
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        image: (product.imagesBase64 != null &&
                                product.imagesBase64!.isNotEmpty)
                            ? MemoryImage(
                                base64Decode(product.imagesBase64!.first))
                            : AssetImage('assets/images/default_image.png')
                                as ImageProvider,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "\$${(product.price * quantity).toStringAsFixed(2)}",
                        style: AppTheme.titleStyle,
                      ),
                      Text(
                        "Quantity: $quantity",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        style: AppTheme.buttonStyle,
                        onPressed: onRemove,
                        child: const Text("Remove"),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
