import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/basket_model.dart';
import '../../shared/model/product_model.dart';
import '../../shared/model/user_model.dart';
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart';
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/home_product_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = '';
  late BasketModel basketModel;
  late Future<User?> _userFuture;
  late User user;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      _userFuture = DatabaseService().getUser(uid);
      _userFuture.then((userData) {
        if (userData != null) {
          setState(() {
            user = userData;
          });
        }
      });
      _refreshProducts();
    } else {
      _navigateToLoginScreen();
    }
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = DatabaseService().getAllProducts();
    });
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<List<Product>> _getFilteredProducts() async {
    final user = await _userFuture;
    final allProducts = await _productsFuture;

    if (user?.isShopOwner ?? false) {
      return allProducts.where((product) => product.ownerUid == uid).toList();
    } else {
      return allProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    basketModel = Provider.of<BasketModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: 'Home'),
      body: FutureBuilder<List<Product>>(
        future: _getFilteredProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                (user.isShopOwner)
                    ? 'You have no products yet'
                    : 'No products available',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            );
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
// In the ListView.builder itemBuilder:
                return HomeProductWidget(
                  product: products[index],
                  addProduct: () => basketModel.addProduct(
                    products[index],
                    quantity: 1,
                  ),
                  isShopOwner: user.isShopOwner,
                  onEditComplete: _refreshProducts, // This is already correct
                );
              },
            );
          }
        },
      ),
    );
  }
}
