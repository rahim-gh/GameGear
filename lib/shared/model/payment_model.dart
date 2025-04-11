import 'package:flutter/material.dart';
import 'package:game_gear/shared/model/basket_model.dart';
import 'package:game_gear/screen/payment/service/payment_service.dart';
import 'package:game_gear/shared/constant/app_config.dart';

enum PaymentStatus {
  idle,
  processing,
  success,
  failed,
}

class PaymentManager extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  PaymentStatus _status = PaymentStatus.idle;
  String? _errorMessage;
  String? _paymentId;

  PaymentStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get paymentId => _paymentId;

  Future<bool> processPayment({
    required BasketModel basketModel,
    required BuildContext context,
    required String cardNumber,
    required String cardExp,
    required String cardCvc,
  }) async {
    if (basketModel.totalPrice <= 0) {
      _errorMessage = 'Cannot process an empty basket';
      _status = PaymentStatus.failed;
      notifyListeners();
      return false;
    }

    try {
      _status = PaymentStatus.processing;
      notifyListeners();

      final result = AppConfig.useTestMode
          ? await _paymentService.simulatePayment(
              amount: basketModel.totalPrice)
          : await _paymentService.processPayment(
              amount: basketModel.totalPrice,
              currency: 'dzd',
              context: context,
              cardNumber: cardNumber,
              cardExp: cardExp,
              cardCvc: cardCvc,
            );

      if (result.success) {
        _status = PaymentStatus.success;
        _paymentId = result.paymentMethodId;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _status = PaymentStatus.failed;
        _errorMessage = result.errorMessage ?? 'Payment failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = PaymentStatus.failed;
      _errorMessage = 'Payment processing error: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = PaymentStatus.idle;
    _errorMessage = null;
    _paymentId = null;
    notifyListeners();
  }
}
