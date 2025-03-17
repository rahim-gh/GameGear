// home_product_widget.dart
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
                      child: Image(
                        width: 120,
                        fit: BoxFit.fill,
                        image: AssetImage(product.imagesBase64?.first ??
                            'assets/images/default_image.png'), // Use the first image or a default image
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
