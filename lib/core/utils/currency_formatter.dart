import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Converts an amount in minor units (paise/cents) to formatted string
  /// e.g. 3000000 -> "₹30,000" or 54250 -> "₹542.50"
  static String formatMinor(
    int amountMinor, {
    String symbol = '₹',
    bool showDecimalsWhenZero = false,
    bool includeSymbol = true,
  }) {
    final double value = amountMinor / 100.0;
    return formatDouble(
      value,
      symbol: symbol,
      showDecimalsWhenZero: showDecimalsWhenZero,
      includeSymbol: includeSymbol,
    );
  }

  /// Converts a double value to formatted currency string
  static String formatDouble(
    double value, {
    String symbol = '₹',
    bool showDecimalsWhenZero = false,
    bool includeSymbol = true,
  }) {
    final bool isNegative = value < 0;
    final double absVal = value.abs();

    final NumberFormat formatter;
    if (absVal % 1 == 0 && !showDecimalsWhenZero) {
      formatter = NumberFormat('#,##,##0', 'en_IN');
    } else {
      formatter = NumberFormat('#,##,##0.00', 'en_IN');
    }

    final String formattedNumber = formatter.format(absVal);
    final String prefix = isNegative ? '-' : '';

    if (!includeSymbol) {
      return '$prefix$formattedNumber';
    }

    return '$prefix$symbol$formattedNumber';
  }

  /// Converts minor units to double
  static double minorToDouble(int amountMinor) {
    return amountMinor / 100.0;
  }

  /// Converts double to minor units (rounding to nearest integer)
  static int doubleToMinor(double amount) {
    return (amount * 100).round();
  }

  /// Parses user string input (e.g. "500", "1250.50") into minor units.
  /// Returns 0 if invalid or empty.
  static int parseInputToMinor(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    final value = double.tryParse(cleaned);
    if (value == null || value.isNaN || value.isInfinite) {
      return 0;
    }
    return (value * 100).round();
  }
}
