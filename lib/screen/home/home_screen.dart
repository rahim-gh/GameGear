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
import '../../shared/widget/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _filteredProductsFuture;
  late Future<User?> _userFuture;
  late String _uid;
  User? _currentUser; // Add this line

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authUser = AuthService().currentUser;
    if (authUser == null) {
      _navigateToLoginScreen();
      return;
    }

    _uid = authUser.uid;
    _userFuture = DatabaseService().getUser(_uid);
    _userFuture.then((user) {
      // Add this block
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _filteredProductsFuture = _loadFilteredProducts();
    });
  }

  Future<List<Product>> _loadFilteredProducts() async {
    final user = await _userFuture;
    final allProducts = await DatabaseService().getAllProducts();

    if (user?.isShopOwner ?? false) {
      return allProducts.where((p) => p.ownerUid == _uid).toList();
    }
    return allProducts;
  }

  void _navigateToLoginScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(
        title: 'Home',
        // actions: [_buildRefreshButton()],
      ),
      body: Consumer<BasketModel>(
        builder: (context, basketModel, _) {
          return FutureBuilder<List<Product>>(
            future: _filteredProductsFuture,
            builder: (context, snapshot) {
              return _buildContent(snapshot);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<List<Product>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const ShimmerLoading();
    }

    if (snapshot.hasError) {
      return _buildErrorState(snapshot.error.toString());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProductGrid(snapshot.data!);
  }

  Widget _buildProductGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: AppTheme.accentColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 8), // Reduced padding
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8), // Less space between cards
                  child: HomeProductWidget(
                    key: ValueKey(products[index].id),
                    product: products[index],
                    onAddToBasket: () =>
                        context.read<BasketModel>().addProduct(products[index]),
                    onEditComplete: _refreshProducts,
                    isShopOwner: _currentUser?.isShopOwner ?? false,
                  ),
                ),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: AppTheme.accentColor),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refreshProducts,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load products',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProducts,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Widget _buildRefreshButton() {
  //   return IconButton(
  //     icon: const Icon(Icons.refresh),
  //     onPressed: _refreshProducts,
  //     tooltip: 'Refresh products',
  //   );
  // }
}
