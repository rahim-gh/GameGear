class AppConfig {
  // Your Stripe publishable key
  static const String stripePublishableKey = 'pk_test_your_publishable_key';

  // Your Stripe secret key - WARNING: In a production app,
  // this should NEVER be stored in the app code.
  // This is only for demonstration purposes.
  static const String stripeSecretKey = 'sk_test_your_secret_key';

  // Flag to enable test mode (without actual Stripe API calls)
  static const bool useTestMode = true;
}
