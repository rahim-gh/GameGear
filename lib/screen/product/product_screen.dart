import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart';
import '../../shared/model/product_model.dart';
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart';
import '../../shared/utils/image_base64.dart';
import '../../shared/utils/logger_util.dart';
import 'screens/edit_product_screen.dart';

class ProductScreen extends StatefulWidget {
  final String productId; // Changed from Product to String ID
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
      _productFuture.then((product) {
        if (product != null && mounted) {
          setState(() {
            _product = product;
          });
        }
      });
    });
  }

  void _decrementQuantity() {
    try {
      if (quantity > 1) {
        setState(() {
          quantity--;
        });
        logs("Decreased quantity to $quantity for ${_product?.name}",
            level: Level.debug);
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
    } catch (error, stackTrace) {
      logs("Error incrementing quantity: $error",
          level: Level.error, error: error, stackTrace: stackTrace);
    }
  }

  void _addToBasket(BasketModel basketModel) {
    if (_product == null) return;

    try {
      basketModel.addProduct(_product!, quantity: quantity);
      logs("Added ${_product!.name} (x$quantity) to basket", level: Level.info);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_product!.name} (x$quantity) added to basket'),
        ),
      );
    } catch (error, stackTrace) {
      logs("Error adding ${_product?.name} to basket: $error",
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
    final isShopOwner = _product != null
        ? AuthService().currentUser?.uid == _product!.ownerUid
        : false;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(_product?.name ?? 'Loading...'),
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
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: product.imagesBase64?.length ?? 0,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: product.name + index.toString(),
                            child: ImageBase64().toProductImage(
                              product.imagesBase64?[index],
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fitHeight,
                            ),
                          );
                        },
                      ),
                      if ((product.imagesBase64?.length ?? 0) > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.imagesBase64?.length ?? 0,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                            child: Center(
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${(product.price * quantity).toStringAsFixed(2)}',
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
                            Row(
                              children: [
                                if (!isShopOwner)
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
                                if (isShopOwner)
                                  Row(
                                    children: [
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        height: 50,
                                        color: AppTheme.accentColor,
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProductScreen(
                                                productId: _product!.id,
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            _loadProduct();
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: AppTheme.primaryColor,
                                              size: 25,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        height: 50,
                                        color: Colors.red,
                                        onPressed: () =>
                                            _deleteProduct(context),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: AppTheme.primaryColor,
                                              size: 25,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Delete',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${_product?.name}?'),
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

    if (confirmed == true && _product != null) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser == null) {
          throw Exception('Please sign in to delete products');
        }

        await DatabaseService().deleteProduct(_product!.id, currentUser.uid);
        if (mounted) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_product!.name} deleted successfully')),
        );
      } on DatabaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }
}
