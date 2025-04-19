import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/service/stripe_service.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

import '../../shared/widget/appbar_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  bool _saveCard = false;
  bool _isProcessing = false;
  String _paymentMethod = 'card'; // Default payment method

  @override
  void initState() {
    super.initState();
    // For testing, you can pre-fill with test card details
    _cardNumberController.text = '4242 4242 4242 4242'; // Test card number
    _validUntilController.text = '12/24';
    _cvvController.text = '123';
    _cardHolderController.text = 'Test User';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _validUntilController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  // Validate card details before submission
  bool _validateCardDetails() {
    logs('Validating card details', level: Level.info);
    
    // Card number validation (16 digits)
    if (_cardNumberController.text.replaceAll(' ', '').length != 16) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid 16-digit card number',
      );
      logs('Invalid card number', level: Level.warning);
      return false;
    }

    // Valid until validation (MM/YY format)
    final validUntil = _validUntilController.text;
    if (validUntil.length != 5 || !validUntil.contains('/')) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid expiration date (MM/YY)',
      );
      logs('Invalid expiration date format', level: Level.warning);
      return false;
    }

    // Split the expiry date to get month and year
    final parts = validUntil.split('/');
    if (parts.length != 2) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid expiration date (MM/YY)',
      );
      logs('Invalid expiration date parts', level: Level.warning);
      return false;
    }

    // Parse month and year
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid month (01-12)',
      );
      logs('Invalid month or year', level: Level.warning);
      return false;
    }

    // Check if card is expired
    final now = DateTime.now();
    final cardYear = 2000 + year; // Convert 2-digit year to 4-digit
    final isExpired = cardYear < now.year || 
                     (cardYear == now.year && month < now.month);
    
    if (isExpired) {
      SnackbarWidget.show(
        context: context,
        message: 'Your card has expired',
      );
      logs('Card has expired', level: Level.warning);
      return false;
    }

    // CVV validation (3 or 4 digits)
    if (_cvvController.text.length < 3 || _cvvController.text.length > 4) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid CVV',
      );
      logs('Invalid CVV', level: Level.warning);
      return false;
    }

    // Card holder validation (non-empty)
    if (_cardHolderController.text.trim().isEmpty) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter the card holder name',
      );
      logs('Empty card holder name', level: Level.warning);
      return false;
    }

    logs('Card validation successful', level: Level.info);
    return true;
  }

  // Process payment with Stripe
  Future<void> _processPayment() async {
    logs('Starting payment process', level: Level.info);
    
    if (!_validateCardDetails()) {
      logs('Card validation failed', level: Level.warning);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final basketModel = Provider.of<BasketModel>(context, listen: false);
      final totalAmount = basketModel.totalPrice;
      
      if (totalAmount <= 0) {
        SnackbarWidget.show(
          context: context,
          message: 'Your basket is empty',
        );
        logs('Attempted payment with empty basket', level: Level.warning);
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      logs('Processing payment for amount: $totalAmount', level: Level.info);
      
      // Split the expiry date to get month and year
      final validUntil = _validUntilController.text;
      final parts = validUntil.split('/');
      final expiryMonth = parts[0];
      final expiryYear = '20${parts[1]}'; // Convert YY to YYYY
      
      logs('Card details: Expiry $expiryMonth/$expiryYear', level: Level.info);
      
      // Process payment with custom card
      final result = await StripeService.processPaymentWithCustomCard(
        amount: totalAmount,
        currency: 'usd', // Change as needed based on your app's requirements
        cardNumber: _cardNumberController.text,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: _cvvController.text,
        cardHolderName: _cardHolderController.text,
        context: context,
      );

      // Check if payment was successful
      if (result['success']) {
        logs('Payment successful', level: Level.info);
        
        // Clear the basket after successful payment
        if (mounted) {
          basketModel.clearBasket();
          logs('Basket cleared after payment', level: Level.info);
        }
        
        // Show success message and return to previous screen
        if (mounted) {
          SnackbarWidget.show(
            context: context,
            message: 'Payment successful!',
            backgroundColor: Colors.green.shade800,
          );

          // Return to previous screen after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              logs('Navigating back after successful payment', level: Level.info);
              Navigator.pop(context);
            }
          });
        }
      } else {
        // Show error message
        logs('Payment failed: ${result['message']}', level: Level.error);
        if (mounted) {
          SnackbarWidget.show(
            context: context,
            message: 'Payment failed: ${result['message']}',
            backgroundColor: Colors.red.shade800,
          );
        }
      }
    } catch (e) {
      // Handle payment error
      logs('Exception during payment: $e', level: Level.error);
      if (mounted) {
        SnackbarWidget.show(
          context: context,
          message: 'Payment failed: ${e.toString()}',
          backgroundColor: Colors.red.shade800,
        );
      }
    } finally {
      // Reset processing state
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        logs('Payment processing state reset', level: Level.info);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        Provider.of<BasketModel>(context, listen: false).totalPrice;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: 'Payment'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceSummary(totalPrice),
              const SizedBox(height: 20),
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              _buildCardForm(),
              const SizedBox(height: 16),
              _buildSaveCardOption(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary(double totalPrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total amount:",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                "\$${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.credit_card, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            const Text(
              "Credit/Debit Card",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        InputFieldWidget(
          label: "Card Number",
          controller: _cardNumberController,
          type: FieldType.normal,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          requiredField: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          prefixIcon: Icon(Icons.credit_card, color: Colors.grey.shade700),
          hintText: "1234 5678 9012 3456",
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InputFieldWidget(
                label: "Valid Until",
                controller: _validUntilController,
                type: FieldType.normal,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                requiredField: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryDateFormatter(),
                ],
                hintText: "MM/YY",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputFieldWidget(
                label: "CVV",
                controller: _cvvController,
                type: FieldType.normal,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                requiredField: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                hintText: "123",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputFieldWidget(
          label: "Card Holder Name",
          controller: _cardHolderController,
          type: FieldType.normal,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.name,
          requiredField: true,
          textCapitalization: TextCapitalization.words,
          hintText: "JOHN DOE",
        ),
      ],
    );
  }

  Widget _buildSaveCardOption() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.save_alt, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                "Save this card for future payments",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Switch(
            value: _saveCard,
            onChanged: (value) {
              setState(() {
                _saveCard = value;
              });
            },
            activeColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Filled black background
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),        onPressed: _isProcessing ? null : _processPayment,
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Complete Payment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
      ),
    );
  }
}

// Custom text input formatter for credit card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (var i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if ((i + 1) % 4 == 0 && i != newText.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Custom text input formatter for MM/YY expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    if (newText.length > 2 && !newText.contains('/')) {
      final firstPart = newText.substring(0, 2);
      final secondPart = newText.substring(2);
      return TextEditingValue(
        text: '$firstPart/$secondPart',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }

    return newValue;
  }
}
