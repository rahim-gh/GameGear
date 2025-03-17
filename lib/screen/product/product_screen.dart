// product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart'; // Add this import
import '../../shared/model/product_model.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final basketModel =
        Provider.of<BasketModel>(context); // Access the basket model

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.product.name,
              child: Image(
                image: AssetImage(widget.product.imagesBase64?.first ??
                    'assets/images/default_image.png'),
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: AppTheme.greyShadeColor, width: 0.5),
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            MaterialButton(
                              color: AppTheme.greyShadeColor,
                              shape: const CircleBorder(),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              },
                              child: Icon(
                                Icons.remove,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text('$quantity'),
                            MaterialButton(
                              color: AppTheme.accentColor,
                              shape: const CircleBorder(),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              child: Icon(
                                Icons.add,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.greyShadeColor, width: 0.5),
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          widget.product.description,
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '\$${(widget.product.price * quantity).toStringAsFixed(2)}',
                                style: AppTheme.titleStyle),
                            Text(
                              'Total payable',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.greyShadeColor),
                            ),
                          ],
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          minWidth: 150,
                          height: 50,
                          color: AppTheme.accentColor,
                          onPressed: () {
                            // Add the product to the basket with the selected quantity
                            basketModel.addProduct(widget.product,
                                quantity: quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${widget.product.name} (x$quantity) added to basket'),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: AppTheme.primaryColor,
                                size: 25,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Add to basket',
                                style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
