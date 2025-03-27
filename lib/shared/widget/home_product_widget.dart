// home_product_widget.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:game_gear/screen/product/screens/product_form_screen.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';

import '../../screen/product/product_screen.dart';
import '../model/product_model.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';

class HomeProductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToBasket;
  final VoidCallback onEditComplete;
  final bool isShopOwner;

  const HomeProductWidget({
    super.key,
    required this.product,
    required this.onAddToBasket,
    required this.onEditComplete,
    required this.isShopOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isShopOwner ? null : () => _navigateToProductScreen(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(context),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProductName(),
                    const SizedBox(height: 4), // Reduced spacing
                    _buildProductPrice(),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Hero(
        tag: product.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image(
              image: _getProductImage(),
              fit: BoxFit.cover, // Crop image to cover the container fully
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getProductImage() {
    if (product.imagesBase64?.isNotEmpty ?? false) {
      return MemoryImage(base64Decode(product.imagesBase64!.first));
    }
    return const AssetImage('assets/default/default_product.png');
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductPrice() {
    return Text(
      '\$${product.price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return isShopOwner
        ? _buildOwnerActions(context)
        : _buildCustomerAction(context);
  }

  Widget _buildCustomerAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.shopping_basket, size: 18, color: Colors.white),
        label: const Text(
          'Add to Basket',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Filled black background
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          onAddToBasket();
          SnackbarWidget.show(
            context: context,
            message: 'Added ${product.name} to basket',
          );
        },
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.black,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(
                    productId: product.id,
                  ),
                ),
              );
              if (result == true) onEditComplete();
            },
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red, // Only color accent
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  void _navigateToProductScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(productId: product.id),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete ${product.name} permanently?'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performDelete(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(BuildContext context) async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) throw Exception('Authentication required');

      await DatabaseService().deleteProduct(product.id, currentUser.uid);
      onEditComplete();

      if (!context.mounted) return;
      SnackbarWidget.show(
        context: context,
        message: 'Deleted ${product.name}',
      );
    } catch (e) {
      if (!context.mounted) return;
      SnackbarWidget.show(
        context: context,
        message: 'Delete failed: ${e.toString()}',
      );
    }
  }
}
