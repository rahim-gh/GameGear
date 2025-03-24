// home_product_widget.dart
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../screen/product/product_screen.dart';
import '../constant/app_theme.dart';
import '../model/product_model.dart'; // Import the Product model

class HomeProductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback addProduct;

  const HomeProductWidget({
    super.key,
    required this.product,
    required this.addProduct,
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
                      borderRadius:
                          BorderRadius.circular(20), // 20 pixel corner radius
                      child: SizedBox(
                        width: 120, // Set the desired width
                        height: 120, // Set the desired height to make it square
                        child: product.imagesBase64?.isNotEmpty == true
                            ? Image.memory(
                                base64Decode(product.imagesBase64!.first),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default_image.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "\$${product.price.toString()}",
                        style: AppTheme.titleStyle,
                      ),
                      ElevatedButton(
                        style: AppTheme.buttonStyle,
                        onPressed: () {
                          addProduct(); // Call the addProduct callback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to basket'),
                            ),
                          );
                        },
                        child: const Text("Add to Basket"),
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
