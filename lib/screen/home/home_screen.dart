import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/itemcard_widget.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  // final String uid;

  const HomeScreen({
    super.key,
    // required this.uid,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // int _selectedIndex = 0;
  User? _currentUser;
  String _userInfo = '';

  final String uid = '0';


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch the user data from Firestore.
      final user = await DatabaseService().getUser(uid);
      if (user == null) {
        setState(() {
          _userInfo = "User not found.";
          _currentUser = null;
        });
        return;
      }
      _currentUser = user;
      String userData = "User: ${user.toString()}";
      // If the user is a shop owner, fetch and display their products.
      if (user.isShopOwner) {
        final products =
            await DatabaseService().getProductsForShopOwner(user.uid);
        userData += "\n\nProducts:\n";
        if (products.isEmpty) {
          userData += "No products found.";
        } else {
          for (final product in products) {
            userData += "$product\n";
          }
        }
      }
      setState(() {
        _userInfo = userData;
      });
    } catch (e) {
      applog('Error loading user data: $e', level: Level.error);
      setState(() {
        _userInfo = "Error loading user data: $e";
      });
    }
  }

  /// Adds a sample product to the shop owner's Firestore subcollection.
  /* Future<void> _addProduct() async {
    if (_currentUser == null || !_currentUser!.isShopOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only shop owners can add products.")),
      );
      return;
    }
    try {
      final Product newProduct = Product(
        id: 0,
        name: "product",
        description: "description",
        price: 23.9,
        tags: ["keyboard", "rgb"],
      );
      final int productId = await DatabaseService()
          .addProductForShopOwner(_currentUser!.uid, newProduct);
      applog("Added product '${newProduct.name}' with product id: $productId",
          level: Level.info);
      await _loadUserData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully.")),
      );
    } catch (e) {
      applog("Error adding product: $e", level: Level.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product: $e")),
      );
    }
  }
 */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBarWidget(title: 'Home'),
      body: ListView.builder(
        itemCount: AppAsset.elements.length,
        itemBuilder: (context, index) {
          return ItemCardWidget(index: index);
        },
      ),
      // floatingActionButton: (_currentUser != null && _currentUser!.isShopOwner)
      //     ? FloatingActionButton(
      //         onPressed: _addProduct,
      //         tooltip: "Add Product",
      //         child: const Icon(Icons.add),
      //       )
      //     : null,

    );
  }
}
