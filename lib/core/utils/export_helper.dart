import '../../domain/models/expense_model.dart';
import '../../domain/models/category_model.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class ExportHelper {
  /// Converts a list of expenses into standard RFC 4180 CSV format
  static String exportTransactionsToCsv({
    required List<ExpenseModel> expenses,
    required Map<String, CategoryModel> categories,
    String currencySymbol = '₹',
  }) {
    final buffer = StringBuffer();

    // Header row
    buffer.writeln(
      'Date,Time,Category,Description,Merchant/Location,Amount ($currencySymbol),Payment Method,Notes',
    );

    for (final exp in expenses) {
      final category = categories[exp.categoryId]?.name ?? 'Uncategorized';
      final row = [
        DateFormatter.toIsoDate(exp.date),
        exp.timeString,
        category,
        exp.description,
        exp.merchant,
        CurrencyFormatter.minorToDouble(exp.amountMinor),
        exp.paymentMethod,
        exp.notes ?? '',
      ];
      buffer.writeln(row.map(_escapeCsvCell).join(','));
    }

    return buffer.toString();
  }

  static String _escapeCsvCell(dynamic value) {
    final str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Generates a readable plain-text financial summary report
  static String generateSummaryText({
    required String title,
    required DateTime dateRangeStart,
    required DateTime dateRangeEnd,
    required int totalExpensesMinor,
    required int totalTransactions,
    required Map<String, int> categoryTotalsMinor,
    required Map<String, CategoryModel> categories,
    String currencySymbol = '₹',
  }) {
    final buffer = StringBuffer();
    buffer.writeln('===========================================');
    buffer.writeln('  SPENDWISE FINANCIAL REPORT');
    buffer.writeln('===========================================');
    buffer.writeln('Title: $title');
    buffer.writeln('Period: ${DateFormatter.formatDate(dateRangeStart)} - ${DateFormatter.formatDate(dateRangeEnd)}');
    buffer.writeln('Generated on: ${DateFormatter.formatDate(DateTime.now())}');
    buffer.writeln('-------------------------------------------');
    buffer.writeln('Total Expenses: ${CurrencyFormatter.formatMinor(totalExpensesMinor, symbol: currencySymbol)}');
    buffer.writeln('Total Transactions: $totalTransactions');
    buffer.writeln('-------------------------------------------');
    buffer.writeln('CATEGORY BREAKDOWN:');

    final sortedEntries = categoryTotalsMinor.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final catName = categories[entry.key]?.name ?? 'Uncategorized';
      final percent = totalExpensesMinor > 0
          ? (entry.value / totalExpensesMinor * 100).toStringAsFixed(1)
          : '0.0';
      buffer.writeln(
        ' • $catName: ${CurrencyFormatter.formatMinor(entry.value, symbol: currencySymbol)} ($percent%)',
      );
    }

    buffer.writeln('===========================================');
    buffer.writeln('SpendWise - Smart Expense Tracker & Daily Budget Manager');
    return buffer.toString();
  }
}
