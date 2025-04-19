import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  final String _secretKey = 'fsgEREeasQ£4reterfwe644rEffsddGSE';

  final String _publishableKey = 'djsDFSfsmdpo55£EDf40r9rfj0wDDFsd';

  final ValidationController _validationController = ValidationController();

  void initializeStripe() {
    Stripe.publishableKey = _publishableKey;
    Stripe.instance.applySettings();
  }

  Future<Map<String, dynamic>> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      final validationResult = _validationController.validateCardDetails(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        cardHolderName: cardHolderName,
      );

      if (!validationResult['isValid']) {
        return {
          'success': false,
          'message': 'Validation failed',
          'errors': validationResult['errors'],
        };
      }

      List<String> expiryParts = expiryDate.split('/');
      int expiryMonth = int.parse(expiryParts[0]);
      int expiryYear = 2000 + int.parse(expiryParts[1]);

      final cardData = {
        'number': cardNumber.replaceAll(' ', ''),
        'exp_month': expiryMonth,
        'exp_year': expiryYear,
        'cvc': cvv,
      };

      final paymentMethodResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_methods'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': 'card',
          'card[number]': cardData['number'],
          'card[exp_month]': cardData['exp_month'].toString(),
          'card[exp_year]': cardData['exp_year'].toString(),
          'card[cvc]': cardData['cvc'],
          'billing_details[name]': cardHolderName,
        },
      );

      final paymentMethodData = jsonDecode(paymentMethodResponse.body);

      if (paymentMethodResponse.statusCode != 200) {
        return {
          'success': false,
          'message':
              'Failed to create payment method: ${paymentMethodData['error']['message']}',
        };
      }

      int amountInSmallestUnit = (amount * 100).toInt();

      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInSmallestUnit.toString(),
          'currency': currency,
          'payment_method': paymentMethodData['id'],
          'confirm': 'true',
          'return_url': 'flutterstripe://payment',
        },
      );

      final paymentIntentData = jsonDecode(paymentIntentResponse.body);

      if (paymentIntentResponse.statusCode != 200) {
        return {
          'success': false,
          'message':
              'Failed to create payment intent: ${paymentIntentData['error']['message']}',
        };
      }

      if (paymentIntentData['status'] == 'requires_action') {
        final clientSecret = paymentIntentData['client_secret'];

        await Stripe.instance.handleNextAction(clientSecret);

        final paymentIntentStatusResponse = await http.get(
          Uri.parse(
              'https://api.stripe.com/v1/payment_intents/${paymentIntentData['id']}'),
          headers: {
            'Authorization': 'Bearer $_secretKey',
          },
        );

        final updatedPaymentIntent =
            jsonDecode(paymentIntentStatusResponse.body);

        if (updatedPaymentIntent['status'] == 'succeeded') {
          return _buildSuccessResponse(
            updatedPaymentIntent['id'],
            amount,
            currency,
            cardNumber,
          );
        } else {
          return {
            'success': false,
            'message': 'Payment authentication failed',
            'status': updatedPaymentIntent['status'],
          };
        }
      } else if (paymentIntentData['status'] == 'succeeded') {
        return _buildSuccessResponse(
          paymentIntentData['id'],
          amount,
          currency,
          cardNumber,
        );
      } else {
        return {
          'success': false,
          'message': 'Payment failed',
          'status': paymentIntentData['status'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment processing error: ${e.toString()}',
      };
    }
  }

  Map<String, dynamic> _buildSuccessResponse(
    String transactionId,
    double amount,
    String currency,
    String cardNumber,
  ) {
    return {
      'success': true,
      'message': 'Payment processed successfully',
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'cardLast4': cardNumber.substring(cardNumber.length - 4),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class ValidationController {
  String? _cardNumberError;
  String? _expiryDateError;
  String? _cvvError;
  String? _cardHolderNameError;

  String? get cardNumberError => _cardNumberError;
  String? get expiryDateError => _expiryDateError;
  String? get cvvError => _cvvError;
  String? get cardHolderNameError => _cardHolderNameError;

  Map<String, dynamic> validateCardDetails({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) {
    _resetValidationErrors();

    bool isCardNumberValid = _validateCardNumber(cardNumber);
    bool isExpiryDateValid = _validateExpiryDate(expiryDate);
    bool isCvvValid = _validateCVV(cvv);
    bool isCardHolderNameValid = _validateCardHolderName(cardHolderName);

    bool isValid = isCardNumberValid &&
        isExpiryDateValid &&
        isCvvValid &&
        isCardHolderNameValid;

    return {
      'isValid': isValid,
      'errors': {
        'cardNumber': _cardNumberError,
        'expiryDate': _expiryDateError,
        'cvv': _cvvError,
        'cardHolderName': _cardHolderNameError,
      }
    };
  }

  void _resetValidationErrors() {
    _cardNumberError = null;
    _expiryDateError = null;
    _cvvError = null;
    _cardHolderNameError = null;
  }

  bool _validateCardNumber(String cardNumber) {
    String sanitizedCardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (sanitizedCardNumber.isEmpty) {
      _cardNumberError = 'Card number is required';
      return false;
    }

    if (sanitizedCardNumber.length != 16) {
      _cardNumberError = 'Card number must be 16 digits';
      return false;
    }

    int sum = 0;
    bool alternate = false;
    for (int i = sanitizedCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(sanitizedCardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      _cardNumberError = 'Invalid card number';
      return false;
    }

    return true;
  }

  bool _validateExpiryDate(String expiryDate) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      _expiryDateError = 'Expiry date must be in MM/YY format';
      return false;
    }

    List<String> parts = expiryDate.split('/');
    int month = int.tryParse(parts[0]) ?? 0;
    int year = int.tryParse(parts[1]) ?? 0;

    if (month < 1 || month > 12) {
      _expiryDateError = 'Invalid month';
      return false;
    }

    int currentYear = DateTime.now().year % 100;
    int currentMonth = DateTime.now().month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      _expiryDateError = 'Card has expired';
      return false;
    }

    if (year > currentYear + 10) {
      _expiryDateError = 'Expiry date too far in the future';
      return false;
    }

    return true;
  }

  bool _validateCVV(String cvv) {
    String sanitizedCVV = cvv.replaceAll(RegExp(r'\D'), '');

    if (sanitizedCVV.isEmpty) {
      _cvvError = 'CVV is required';
      return false;
    }

    if (sanitizedCVV.length < 3 || sanitizedCVV.length > 4) {
      _cvvError = 'CVV must be 3 or 4 digits';
      return false;
    }

    return true;
  }

  bool _validateCardHolderName(String cardHolderName) {
    if (cardHolderName.trim().isEmpty) {
      _cardHolderNameError = 'Cardholder name is required';
      return false;
    }

    List<String> nameParts = cardHolderName.trim().split(' ');
    if (nameParts.length < 2) {
      _cardHolderNameError = 'Please enter full name';
      return false;
    }

    if (!RegExp(r"^[a-zA-Z\s.\',-]+$").hasMatch(cardHolderName)) {
      _cardHolderNameError = 'Name can only contain letters and spaces';
      return false;
    }

    return true;
  }
}
