import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:provider/provider.dart';

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
    // Card number validation (16 digits)
    if (_cardNumberController.text.replaceAll(' ', '').length != 16) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid 16-digit card number',
      );
      return false;
    }

    // Valid until validation (MM/YY format)
    final validUntil = _validUntilController.text;
    if (validUntil.length != 5 || validUntil[2] != '/') {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid expiration date (MM/YY)',
      );
      return false;
    }

    try {
      // Extract month and year
      final parts = validUntil.split('/');
      if (parts.length != 2) {
        throw FormatException('Invalid date format');
      }

      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]) + 2000; // Convert YY to 20YY

      // Validate month (1-12)
      if (month < 1 || month > 12) {
        SnackbarWidget.show(
          context: context,
          message: 'Please enter a valid month (01-12)',
        );
        return false;
      }

      // Get current date
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Check if card is expired
      if (year < currentYear || (year == currentYear && month < currentMonth)) {
        SnackbarWidget.show(
          context: context,
          message: 'Card has expired',
        );
        return false;
      }
    } catch (e) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid expiration date (MM/YY)',
      );
      return false;
    }

    // CVV validation (3 or 4 digits)
    if (_cvvController.text.length < 3 || _cvvController.text.length > 4) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid CVV',
      );
      return false;
    }

    // Card holder validation (non-empty)
    if (_cardHolderController.text.trim().isEmpty) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter the card holder name',
      );
      return false;
    }

    return true;
  }

  // Process payment
  Future<void> _processPayment() async {
    if (!_validateCardDetails()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Clear the basket after successful payment
      if (mounted) {
        final basketModel = Provider.of<BasketModel>(context, listen: false);
        basketModel.clearBasket();
      }

      // Processing complete
      setState(() {
        _isProcessing = false;
      });

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
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // Handle payment error
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        SnackbarWidget.show(
          context: context,
          message: 'Payment failed: ${e.toString()}',
          backgroundColor: Colors.red.shade800,
        );
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
        style: AppTheme.buttonStyle,
        onPressed: _isProcessing ? null : _processPayment,
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

// Improved text input formatter for MM/YY expiry date
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text.replaceAll('/', '');
    final oldText = oldValue.text.replaceAll('/', '');

    // Handle deletion
    if (newText.length < oldText.length) {
      // If deleting the slash, also delete the character before it
      if (oldValue.text.contains('/') &&
          oldValue.selection.baseOffset == 3 &&
          newValue.selection.baseOffset == 2) {
        newText = newText.substring(0, 1);
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }

      // Return with proper formatting for remaining text
      if (newText.length <= 2) {
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      } else {
        return TextEditingValue(
          text: '${newText.substring(0, 2)}/${newText.substring(2)}',
          selection: TextSelection.collapsed(offset: newText.length + 1),
        );
      }
    }

    // Limit to 4 digits
    if (newText.length > 4) {
      newText = newText.substring(0, 4);
    }

    // Format with slash
    if (newText.length > 2) {
      final month = newText.substring(0, 2);
      final year = newText.substring(2);

      // Try to validate month (1-12)
      try {
        final monthNum = int.parse(month);
        if (monthNum < 1) {
          newText = '01${newText.substring(2)}';
        } else if (monthNum > 12) {
          newText = '12${newText.substring(2)}';
        }
      } catch (_) {
        // If month isn't a valid number, leave as is
      }

      return TextEditingValue(
        text: '$month/$year',
        selection:
            TextSelection.collapsed(offset: month.length + year.length + 1),
      );
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
