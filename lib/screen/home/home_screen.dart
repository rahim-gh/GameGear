// home_screen.dart
import 'package:flutter/material.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/model/product_model.dart'; // Import the Product model
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart'; // New import for DB operations
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/home_product_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String uid = AuthService().currentUser!.uid;
  late BasketModel basketModel;

  @override
  Widget build(BuildContext context) {
    basketModel = Provider.of<BasketModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: 'Home'),
      body: FutureBuilder<List<Product>>(
        future:
            DatabaseService().getAllProducts(), // Fetch products from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return HomeProductWidget(
                  product: products[index],
                  addProduct: () => basketModel.addProduct(
                    products[index],
                    quantity: 1,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
