// home_screen.dart
import 'package:flutter/material.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:provider/provider.dart';

import '../../shared/constant/app_data.dart';
import '../../shared/constant/app_theme.dart';
import '../../shared/service/auth_service.dart';
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

  // Access the basket model
  @override
  Widget build(BuildContext context) {
    basketModel = Provider.of<BasketModel>(context);
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBarWidget(title: 'Home'),
      body: ListView.builder(
        itemCount: AppData.products.length,
        itemBuilder: (context, index) {
          return HomeProductWidget(
            product: AppData.products[index],
            addProduct: () => basketModel.addProduct(
              AppData.products[index],
              quantity: 1, // Pass a default quantity of 1
            ),
          );
        },
      ),
    );
  }
}
