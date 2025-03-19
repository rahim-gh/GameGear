import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart';
import '../../shared/model/product_model.dart';
import '../../shared/utils/logger_util.dart'; // For logging

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;

  void _decrementQuantity() {
    try {
      if (quantity > 1) {
        setState(() {
          quantity--;
        });
        logs("Decreased quantity to $quantity for ${widget.product.name}",
            level: Level.debug);
      } else {
        logs("Attempt to reduce quantity below 1 for ${widget.product.name}",
            level: Level.warning);
      }
    } catch (error, stackTrace) {
      logs("Error decrementing quantity: $error",
          level: Level.error, error: error, stackTrace: stackTrace);
    }
  }

  void _incrementQuantity() {
    try {
      setState(() {
        quantity++;
      });
      logs("Increased quantity to $quantity for ${widget.product.name}",
          level: Level.debug);
    } catch (error, stackTrace) {
      logs("Error incrementing quantity: $error",
          level: Level.error, error: error, stackTrace: stackTrace);
    }
  }

  void _addToBasket(BasketModel basketModel) {
    try {
      basketModel.addProduct(widget.product, quantity: quantity);
      logs("Added ${widget.product.name} (x$quantity) to basket",
          level: Level.info);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} (x$quantity) added to basket'),
        ),
      );
    } catch (error, stackTrace) {
      logs("Error adding ${widget.product.name} to basket: $error",
          level: Level.error, error: error, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product to basket: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketModel = Provider.of<BasketModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.product.name,
              child: Image(
                image: AssetImage(
                  widget.product.imagesBase64?.first ??
                      'assets/images/default_image.png',
                ),
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.greyShadeColor, width: 0.5),
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
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
                              onPressed: _decrementQuantity,
                              child: Icon(
                                Icons.remove,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text('$quantity'),
                            MaterialButton(
                              color: AppTheme.accentColor,
                              shape: const CircleBorder(),
                              onPressed: _incrementQuantity,
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
                            fontWeight: FontWeight.w500,
                          ),
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
                              style: AppTheme.titleStyle,
                            ),
                            Text(
                              'Total payable',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.greyShadeColor,
                              ),
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
                          onPressed: () => _addToBasket(basketModel),
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
                                  fontSize: 16,
                                ),
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
