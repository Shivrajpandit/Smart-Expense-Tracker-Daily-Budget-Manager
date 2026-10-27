class AppConstants {
  static const String appName = 'SpendWise';
  static const String appTagline = 'Smart Expense Tracker & Daily Budget Manager';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const int defaultMonthlyBudgetMinor = 3000000; // ₹30,000.00 in minor units (paise)

  // Payment methods
  static const List<String> paymentMethods = [
    'UPI',
    'Cash',
    'Credit Card',
    'Debit Card',
    'Net Banking',
    'Other',
  ];

  // Budget alert thresholds (percentage of daily/monthly allowance)
  static const double alertThreshold50 = 50.0;
  static const double alertThreshold80 = 80.0;
  static const double alertThreshold100 = 100.0;
}
