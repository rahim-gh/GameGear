import 'dart:convert';

import 'package:flutter/material.dart';

import '../../screen/product/product_screen.dart';
import '../../screen/product/screens/edit_product_screen.dart';
import '../constant/app_theme.dart';
import '../model/product_model.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';

class HomeProductWidget extends StatefulWidget {
  final Product product;
  final bool isShopOwner;
  final VoidCallback addProduct;
  final VoidCallback onEditComplete;

  const HomeProductWidget({
    super.key,
    required this.product,
    required this.isShopOwner,
    required this.addProduct,
    required this.onEditComplete,
  });

  @override
  State<HomeProductWidget> createState() => _HomeProductWidgetState();
}

class _HomeProductWidgetState extends State<HomeProductWidget> {
  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${widget.product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser == null) {
          throw Exception('Please sign in to delete products');
        }

        await DatabaseService()
            .deleteProduct(widget.product.id, currentUser.uid);
        widget.onEditComplete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${widget.product.name} deleted successfully')),
        );
      } on DatabaseException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductScreen(productId: widget.product.id);
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
                widget.product.name,
                style: AppTheme.titleStyle,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// In the build method of _HomeProductWidgetState, update the Hero widget:
                  Hero(
                    tag:
                        '${widget.product.name}0', // Use first image index for home screen
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: widget.product.imagesBase64?.isNotEmpty == true
                            ? Image.memory(
                                base64Decode(
                                    widget.product.imagesBase64!.first),
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
                        "\$${widget.product.price.toString()}",
                        style: AppTheme.titleStyle,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: AppTheme.buttonStyle,
// Change the Edit button onPressed in build method:
                        onPressed: () async {
                          if (!widget.isShopOwner) {
                            widget.addProduct();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${widget.product.name} added to basket'),
                              ),
                            );
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                  productId: widget.product.id,
                                ),
                              ),
                            );

                            if (result == true) {
                              widget
                                  .onEditComplete(); // Trigger refresh in HomeScreen
                            }
                          }
                        },
                        child: Text(
                            !widget.isShopOwner ? "Add to Basket" : "Edit"),
                      ),
                      if (widget.isShopOwner)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                            style: AppTheme.buttonStyle.copyWith(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            onPressed: () => _deleteProduct(context),
                            child: const Text("Delete"),
                          ),
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
