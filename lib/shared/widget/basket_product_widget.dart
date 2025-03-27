import 'dart:convert';

import 'package:flutter/material.dart';

import '../../screen/product/product_screen.dart';
import '../constant/app_theme.dart';
import '../model/product_model.dart';

class BasketProductWidget extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemoveAll;

  const BasketProductWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProductScreen(context),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProductImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductName(),
                    const SizedBox(height: 8),
                    _buildPriceTotal(),
                    const SizedBox(height: 8),
                    _buildIconControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: product.id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          image: _getProductImage(),
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        ),
      ),
    );
  }

  ImageProvider _getProductImage() {
    if (product.imagesBase64?.isNotEmpty ?? false) {
      return MemoryImage(base64Decode(product.imagesBase64!.first));
    }
    return const AssetImage('assets/images/default_image.png');
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/images/default_image.png',
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: AppTheme.titleStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceTotal() {
    return Text(
      "\$${(product.price * quantity).toStringAsFixed(2)}",
      style: AppTheme.titleStyle.copyWith(
        fontSize: 18,
        color: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildIconControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.accentColor,
          onPressed: onDecrement,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.accentColor,
          onPressed: onIncrement,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          color: Colors.red,
          onPressed: onRemoveAll,
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
}
