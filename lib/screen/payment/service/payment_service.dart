import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:game_gear/shared/constant/app_config.dart';

/// A service class to handle payment processing with Stripe.
class PaymentService {
  // Singleton pattern implementation
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Configuration keys from app config
  final String _publishableKey = AppConfig.stripePublishableKey;
  final String _secretKey = AppConfig.stripeSecretKey;

  /// Initialize the Stripe SDK with publishable key
  Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Parse card expiration date in MM/YY format
  Map<String, int> _parseExpirationDate(String cardExp) {
    final parts = cardExp.split('/');
    if (parts.length != 2) {
      throw PaymentException(
          'Invalid expiration date format. Use MM/YY format.');
    }

    final expMonth = int.tryParse(parts[0]);
    final expYear = int.tryParse('20${parts[1]}');

    if (expMonth == null || expYear == null) {
      throw PaymentException('Invalid expiration date values');
    }

    if (expMonth < 1 || expMonth > 12) {
      throw PaymentException('Invalid expiration month');
    }

    return {'month': expMonth, 'year': expYear};
  }

  /// Create a payment intent with card details
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String cardNumber,
    required String cardExp,
    required String cardCvc,
  }) async {
    try {
      // Convert dollar amount to cents
      final int amountInCents = (amount * 100).round();

      // Parse the expiration date
      final expiration = _parseExpirationDate(cardExp);

      // Create payment method for card details
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(), // Add customer details if needed
          ),
        ),
      );

      // In a real application, you would call your backend to create a PaymentIntent
      // For this example, we're simulating the response
      // NOTE: In production, NEVER create PaymentIntents on the client side

      final simulatedPaymentIntentId =
          'pi_${DateTime.now().millisecondsSinceEpoch}';
      final clientSecret =
          'pi_${DateTime.now().millisecondsSinceEpoch}_secret_${paymentMethod.id}';

      return {
        'id': simulatedPaymentIntentId,
        'client_secret': clientSecret,
        'payment_method_id': paymentMethod.id,
        'amount': amountInCents,
        'currency': currency,
      };
    } catch (e) {
      throw PaymentException('Error creating payment intent: $e');
    }
  }

  /// Process a payment with the provided card details
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required BuildContext context,
    required String cardNumber,
    required String cardExp,
    required String cardCvc,
  }) async {
    try {
      // Validate inputs
      if (cardNumber.isEmpty || cardExp.isEmpty || cardCvc.isEmpty) {
        throw PaymentException('Card details cannot be empty');
      }

      if (amount <= 0) {
        throw PaymentException('Amount must be greater than zero');
      }

      // Create payment intent data
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        cardNumber: cardNumber,
        cardExp: cardExp,
        cardCvc: cardCvc,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Game Gear Shop',
          style: ThemeMode.dark,
          // Link the PaymentMethod to the PaymentIntent
          setupIntentClientSecret: null,
          customerId: null,
          customerEphemeralKeySecret: null,
          primaryButtonLabel: 'Pay ${amount.toStringAsFixed(2)} $currency',
        ),
      );

      // Present and confirm payment sheet
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntentData['id'],
        paymentMethodId: paymentIntentData['payment_method_id'],
        amount: amount,
        currency: currency,
        timestamp: DateTime.now(),
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage,
        errorCode: e.error.code.toString(),
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Payment failed: $e',
      );
    }
  }

  /// Process payment with an existing PaymentMethod ID
  Future<PaymentResult> processPaymentWithExistingMethod({
    required double amount,
    required String currency,
    required String paymentMethodId,
    required BuildContext context,
  }) async {
    try {
      // Convert dollar amount to cents
      final int amountInCents = (amount * 100).round();

      // In production, you would call your backend to create a PaymentIntent with the existing PaymentMethod
      // Here we're simulating the client_secret response
      final clientSecret =
          'pi_${DateTime.now().millisecondsSinceEpoch}_secret_$paymentMethodId';

      final params = PaymentMethodParams.cardFromMethodId(
        paymentMethodData: PaymentMethodDataCardFromMethod(
          paymentMethodId: paymentMethodId,
        ),
      );

      // Confirm the payment with the existing payment method
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: params,
      );

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntent.id,
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: currency,
        timestamp: DateTime.now(),
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.error.localizedMessage,
        errorCode: e.error.code.toString(),
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Payment failed: $e',
      );
    }
  }

  /// Create a PaymentMethod without immediately charging
  Future<String?> createSavedPaymentMethod({
    required String cardNumber,
    required String cardExp,
    required String cardCvc,
    String? customerName,
  }) async {
    try {
      final expiration = _parseExpirationDate(cardExp);

      // Create payment method for card details
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: customerName,
            ),
          ),
        ),
      );

      return paymentMethod.id;
    } catch (e) {
      throw PaymentException('Failed to save payment method: $e');
    }
  }

  /// Simulate a payment process for testing
  Future<PaymentResult> simulatePayment({
    required double amount,
    String currency = 'USD',
    bool shouldSucceed = true,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!shouldSucceed) {
      return PaymentResult(
        success: false,
        errorMessage: 'Simulated payment failure',
        errorCode: 'simulation_error',
      );
    }

    final paymentIntentId = 'pi_sim_${DateTime.now().millisecondsSinceEpoch}';
    final paymentMethodId = 'pm_sim_${DateTime.now().millisecondsSinceEpoch}';

    return PaymentResult(
      success: true,
      paymentIntentId: paymentIntentId,
      paymentMethodId: paymentMethodId,
      amount: amount,
      currency: currency,
      timestamp: DateTime.now(),
    );
  }
}

/// Custom exception for payment-related errors
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}

/// Result model for payment operations
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? paymentMethodId;
  final String? errorMessage;
  final String? errorCode;
  final double? amount;
  final String? currency;
  final DateTime? timestamp;

  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.paymentMethodId,
    this.errorMessage,
    this.errorCode,
    this.amount,
    this.currency,
    this.timestamp,
  });

  /// Check if result contains an error
  bool get hasError => !success && (errorMessage != null || errorCode != null);

  @override
  String toString() {
    if (success) {
      return 'Payment successful: Intent=$paymentIntentId, Method=$paymentMethodId, Amount=$amount $currency';
    } else {
      return 'Payment failed: $errorMessage (Code: $errorCode)';
    }
  }
}
