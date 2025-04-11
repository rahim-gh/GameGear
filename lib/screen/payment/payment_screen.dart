import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_config.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/model/payment_model.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardCvcController = TextEditingController();
  final _cardExpController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardCvcController.dispose();
    _cardExpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: const AppBarWidget(title: "Checkout"),
      body: Consumer2<BasketModel, PaymentManager>(
        builder: (context, basketModel, paymentManager, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(basketModel),
                const SizedBox(height: 30),
                _buildCardForm(),
                const SizedBox(height: 30),
                _buildPaymentButton(context, basketModel, paymentManager),
                if (AppConfig.useTestMode) _buildTestModeNotice(),
                if (paymentManager.status == PaymentStatus.failed)
                  _buildErrorMessage(paymentManager.errorMessage),
                if (paymentManager.status == PaymentStatus.success)
                  _buildSuccessMessage(paymentManager.paymentId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BasketModel basketModel) {
    return Card(
      color: AppTheme.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            ...basketModel.products.entries
                .where((e) => e.value > 0)
                .map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${entry.key.name} x ${entry.value}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      '\$${(entry.key.price * entry.value).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(color: Colors.white30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.accentColor,
                  ),
                ),
                Text(
                  '\$${basketModel.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          // Card Number Field
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              labelStyle:
                  TextStyle(color: AppTheme.accentColor.withOpacity(0.8)),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentColor),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: AppTheme.secondaryColor,
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your card number';
              }
              // Basic check: usually card numbers are between 13 to 19 digits.
              if (!RegExp(r'^\d{13,19}$').hasMatch(value.replaceAll(' ', ''))) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Expiration Date Field (mm/yy)
          TextFormField(
            controller: _cardExpController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Expiry Date (mm/yy)',
              labelStyle:
                  TextStyle(color: AppTheme.accentColor.withOpacity(0.8)),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentColor),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: AppTheme.secondaryColor,
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter expiry date';
              }
              // Simple validation for mm/yy format
              if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                return 'Enter expiry as mm/yy';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // CVC Field
          TextFormField(
            controller: _cardCvcController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'CVC',
              labelStyle:
                  TextStyle(color: AppTheme.accentColor.withOpacity(0.8)),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentColor),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              filled: true,
              fillColor: AppTheme.secondaryColor,
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter CVC';
              }
              // Typically 3 or 4 digits
              if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
                return 'Enter a valid CVC';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(
    BuildContext context,
    BasketModel basketModel,
    PaymentManager paymentManager,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: AppTheme.primaryColor,
        ),
        onPressed: _isProcessing || basketModel.totalPrice <= 0
            ? null
            : () => _handlePayment(context, basketModel, paymentManager),
        child: _isProcessing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildTestModeNotice() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade200, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Test Mode: No actual payment will be processed',
              style: TextStyle(color: Colors.amber.shade200, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String? message) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message ?? 'Payment failed. Please try again.',
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(String? paymentId) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade900.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade300),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade300,
                    ),
                  ),
                ),
              ],
            ),
            if (paymentId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Payment ID: $paymentId',
                style: TextStyle(color: Colors.green.shade300),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    BasketModel basketModel,
    PaymentManager paymentManager,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Pass the card info directly into the payment process.
    final success = await paymentManager.processPayment(
      basketModel: basketModel,
      context: context,
      cardNumber: _cardNumberController.text.trim(),
      cardExp: _cardExpController.text.trim(),
      cardCvc: _cardCvcController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (success) {
      SnackbarWidget.show(
        context: context,
        message: 'Payment successful! Thank you for your order.',
      );
      basketModel.clearBasket();
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }
}
