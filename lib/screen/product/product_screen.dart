import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart';
import '../../shared/model/product_model.dart';
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/logger_util.dart';
import 'screens/product_form_screen.dart';

class ProductScreen extends StatefulWidget {
  final String productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;
  int _currentImageIndex = 0;
  late Future<Product?> _productFuture;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    setState(() {
      _productFuture = DatabaseService().getProduct(widget.productId);
    });
    _productFuture.then((product) {
      if (product != null && mounted) {
        setState(() {
          _product = product;
        });
      }
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() => quantity--);
      logs("Quantity decreased to $quantity", level: Level.debug);
    }
  }

  void _incrementQuantity() {
    setState(() => quantity++);
    logs("Quantity increased to $quantity", level: Level.debug);
  }

  void _addToBasket(BasketModel basketModel) {
    if (_product == null) return;
    try {
      basketModel.addProduct(_product!, quantity: quantity);
      logs("Added ${_product!.name} x$quantity to basket", level: Level.info);
      SnackbarWidget.show(
        context: context,
        message: '${_product!.name} (x$quantity) added to basket',
      );
    } catch (error, stackTrace) {
      logs("Error adding product to basket: $error",
          level: Level.error, error: error, stackTrace: stackTrace);
      SnackbarWidget.show(
        context: context,
        message: 'Error adding product: $error',
      );
    }
  }

  Widget _buildHeroImages(Product product) {
    final imageCount = product.imagesBase64?.length ?? 0;
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.7,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: imageCount,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Hero(
                tag: '${product.name}_$index',
                child: ImageBase64().toProductImage(
                  product.imagesBase64?[index],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          if (imageCount > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageCount,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppTheme.accentColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(Product product, BasketModel basketModel) {
    // Determine if current user is the owner of the product.
    final isShopOwner = AuthService().currentUser?.uid == product.ownerUid;
    return Container(
      padding: const EdgeInsets.only(top: 25),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border.all(color: AppTheme.greyShadeColor, width: 0.5),
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
              product.name,
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: quantity > 1
                      ? AppTheme.accentColor
                      : AppTheme.greyShadeColor,
                  shape: const CircleBorder(),
                  onPressed: _decrementQuantity,
                  child: Icon(Icons.remove, color: AppTheme.primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child:
                      Text('$quantity', style: const TextStyle(fontSize: 18)),
                ),
                MaterialButton(
                  color: AppTheme.accentColor,
                  shape: const CircleBorder(),
                  onPressed: _incrementQuantity,
                  child: Icon(Icons.add, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                border: Border.all(color: AppTheme.greyShadeColor, width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${(product.price * quantity).toStringAsFixed(2)}',
                        style: AppTheme.titleStyle),
                    const SizedBox(height: 5),
                    const Text('Total payable',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (!isShopOwner)
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    minWidth: 150,
                    height: 50,
                    color: AppTheme.accentColor,
                    onPressed: () => _addToBasket(basketModel),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart,
                            color: AppTheme.primaryColor, size: 25),
                        const SizedBox(width: 8),
                        Text('Add to basket',
                            style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        height: 50,
                        color: AppTheme.accentColor,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductFormScreen(productId: product.id)),
                          );
                          if (result == true) {
                            _loadProduct();
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                color: AppTheme.primaryColor, size: 25),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        height: 50,
                        color: Colors.red,
                        onPressed: () => _deleteProduct(context),
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: AppTheme.primaryColor, size: 25),
                            const SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${_product?.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && _product != null) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser == null) {
          throw Exception('Please sign in to delete products');
        }
        await DatabaseService().deleteProduct(_product!.id, currentUser.uid);
        if (mounted) Navigator.pop(context);
        SnackbarWidget.show(
          context: context,
          message: '${_product!.name} deleted successfully',
        );
      } on Exception catch (e) {
        if (!mounted) return;
        SnackbarWidget.show(
          context: context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketModel = Provider.of<BasketModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(_product?.name ?? 'Loading...'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          }
          final product = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroImages(product),
                _buildProductDetails(product, basketModel),
              ],
            ),
          );
        },
      ),
    );
  }
}
