import 'package:flutter/material.dart';
import 'package:game_gear/screen/payment/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/basket_product_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: const AppBarWidget(title: "Basket"),
      body: Consumer<BasketModel>(
        builder: (context, basketModel, _) {
          return Column(
            children: [
              _buildTotalSection(context, basketModel),
              Expanded(child: _buildProductList(context, basketModel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, BasketModel basketModel) {
    return Material(
      elevation: 4,
      color: AppTheme.primaryColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${basketModel.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: AppTheme.buttonStyle,
              onPressed: () => _handleClear(context, basketModel),
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              style: AppTheme.buttonStyle,
              onPressed: () => _handlePurchase(context, basketModel),
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, BasketModel basketModel) {
    final products =
        basketModel.products.entries.where((e) => e.value > 0).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = products[index];
        return BasketProductWidget(
          product: entry.key,
          quantity: entry.value,
          onDecrement: () => basketModel.removeProductQuantity(entry.key, 1),
          onIncrement: () => basketModel.addProduct(entry.key, quantity: 1),
          onRemoveAll: () {
            basketModel.removeProduct(entry.key);
            SnackbarWidget.show(
              context: context,
              message: '${entry.key.name} removed',
              actionLabel: 'Undo',
              onActionPressed: () =>
                  basketModel.addProduct(entry.key, quantity: entry.value),
            );
          },
        );
      },
    );
  }

  void _handlePurchase(BuildContext context, BasketModel basketModel) {
    if (basketModel.products.isEmpty) {
      SnackbarWidget.show(
        context: context,
        message: 'The basket is empty',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
    // Note: Moving clearBasket to the payment screen after successful payment
    // instead of clearing here to preserve the basket until payment is confirmed
    SnackbarWidget.show(
      context: context,
      message: 'Proceeding to payment',
    );
  }

  void _handleClear(BuildContext context, BasketModel basketModel) {
    if (basketModel.products.isEmpty) return;
    basketModel.clearBasket();
    SnackbarWidget.show(
      context: context,
      message: 'The basket cleared',
    );
  }
}
