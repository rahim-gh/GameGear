import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class StripeService {
  // Your Stripe publishable key
  static const String publishableKey = 'pk_test_51PBpnmAiOoqBOgbgENEwcvBCgKR2U3XbYasmT0EqJSUuQXXXsT2ZvbfW4wh7k6AOp22eZofPQMJuBcOk3SZpYvDP00CwVgfvlE';
  
  // Your Firebase Cloud Function URL for creating payment intents
  static const String paymentIntentUrl = 'https://us-central1-gamegear-59846.cloudfunctions.net/createPaymentIntent';
  
  // Initialize Stripe
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      logs('Stripe initialized successfully', level: Level.info);
    } catch (e) {
      logs('Failed to initialize Stripe: $e', level: Level.error);
      rethrow;
    }
  }
  
  // Process card payment using card details
  static Future<Map<String, dynamic>> processCardPayment({
    required double amount,
    required String currency,
    required BuildContext context,
  }) async {
    try {
      logs('Processing card payment: $amount $currency', level: Level.info);
      
      // Step 1: Create payment intent on the server
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );
      
      if (paymentIntent == null) {
        logs('Failed to create payment intent', level: Level.error);
        throw Exception('Failed to create payment intent');
      }
      
      logs('Payment intent created: ${paymentIntent['id']}', level: Level.info);
      
      // Step 2: Confirm the payment with the card details
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      logs('Payment confirmed successfully', level: Level.info);
      
      // If we reach here, payment was successful
      return {'success': true, 'message': 'Payment successful'};
      
    } on StripeException catch (e) {
      // Handle Stripe-specific exceptions
      logs('Stripe exception: ${e.error.localizedMessage}', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'Error: ${e.error.localizedMessage}',
        backgroundColor: Colors.red.shade800,
      );
      return {'success': false, 'message': e.error.localizedMessage};
      
    } catch (e) {
      // Handle other exceptions
      logs('Payment error: $e', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'Error: ${e.toString()}',
        backgroundColor: Colors.red.shade800,
      );
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Process payment with a custom card
  static Future<Map<String, dynamic>> processPaymentWithCustomCard({
    required double amount,
    required String currency,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardHolderName,
    required BuildContext context,
  }) async {
    try {
      logs('Processing custom card payment: $amount $currency', level: Level.info);
      
      // Create card details
      final cardDetails = CardDetails(
        number: cardNumber.replaceAll(' ', ''),
        expiryMonth: int.parse(expiryMonth),
        expiryYear: int.parse(expiryYear),
        cvc: cvc,
      );
      
      logs('Card details created', level: Level.info);
      
      // Create billing details
      final billingDetails = BillingDetails(
        name: cardHolderName,
      );
      
      // Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );
      
      logs('Payment method created: ${paymentMethod.id}', level: Level.info);
      
      // Step 1: Create payment intent on the server
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );
      
      if (paymentIntent == null) {
        logs('Failed to create payment intent', level: Level.error);
        throw Exception('Failed to create payment intent');
      }
      
      logs('Payment intent created: ${paymentIntent['id']}', level: Level.info);
      
      // Step 2: Confirm payment with the payment method
      final confirmPaymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );
      
      logs('Payment confirmed successfully', level: Level.info);
      
      // If we reach here, payment was successful
      return {'success': true, 'message': 'Payment successful'};
      
    } on StripeException catch (e) {
      // Handle Stripe-specific exceptions
      logs('Stripe exception: ${e.error.localizedMessage}', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'Error: ${e.error.localizedMessage}',
        backgroundColor: Colors.red.shade800,
      );
      return {'success': false, 'message': e.error.localizedMessage};
      
    } catch (e) {
      // Handle other exceptions
      logs('Payment error: $e', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'Error: ${e.toString()}',
        backgroundColor: Colors.red.shade800,
      );
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Create a payment intent on the server
  static Future<Map<String, dynamic>?> _createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      // The amount should be in the smallest currency unit (e.g., cents for USD)
      final amountInSmallestUnit = (amount * 100).toInt();
      
      logs('Creating payment intent: $amountInSmallestUnit $currency', level: Level.info);
      
      // Make a real API call to your backend to create a payment intent
      final response = await http.post(
        Uri.parse(paymentIntentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInSmallestUnit,
          'currency': currency,
        }),
      );
      
      if (response.statusCode != 200) {
        logs('Payment intent creation failed: ${response.body}', level: Level.error);
        throw Exception('Failed to create payment intent: ${response.statusCode} ${response.body}');
      }
      
      final responseData = jsonDecode(response.body);
      logs('Payment intent created successfully', level: Level.info);
      return responseData;
      
    } catch (e) {
      logs('Error creating payment intent: $e', level: Level.error);
      return null;
    }
  }
}