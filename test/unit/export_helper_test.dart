import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/export_helper.dart';
import 'package:spendwise/domain/models/category_model.dart';
import 'package:spendwise/domain/models/expense_model.dart';

void main() {
  group('ExportHelper Tests', () {
    test('exports transactions to CSV accurately', () {
      final category = const CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        iconCodePoint: 0xe532,
        colorValue: 0xFFFF7043,
      );

      final expense = ExpenseModel(
        id: 'test_1',
        amountMinor: 25050, // ₹250.50
        categoryId: 'cat_food',
        description: 'Dinner at Bistro',
        merchant: 'Bistro Cafe',
        date: DateTime(2026, 10, 27),
        timeString: '08:30 PM',
        paymentMethod: 'UPI',
        notes: 'With family',
        createdAt: DateTime(2026, 10, 27, 20, 30),
        updatedAt: DateTime(2026, 10, 27, 20, 30),
      );

      final csv = ExportHelper.exportTransactionsToCsv(
        expenses: [expense],
        categories: {'cat_food': category},
        currencySymbol: '₹',
      );

      expect(csv.contains('Date,Time,Category,Description,Merchant/Location,Amount (₹),Payment Method,Notes'), isTrue);
      expect(csv.contains('2026-10-27,08:30 PM,Food & Dining,Dinner at Bistro,Bistro Cafe,250.5,UPI,With family'), isTrue);
    });

    test('generates formatted financial summary report', () {
      final category = const CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        iconCodePoint: 0xe532,
        colorValue: 0xFFFF7043,
      );

      final summary = ExportHelper.generateSummaryText(
        title: 'Monthly Summary',
        dateRangeStart: DateTime(2026, 10, 1),
        dateRangeEnd: DateTime(2026, 10, 31),
        totalExpensesMinor: 1500000, // ₹15,000
        totalTransactions: 12,
        categoryTotalsMinor: {'cat_food': 1500000},
        categories: {'cat_food': category},
        currencySymbol: '₹',
      );

      expect(summary.contains('SPENDWISE FINANCIAL REPORT'), isTrue);
      expect(summary.contains('Total Expenses: ₹15,000'), isTrue);
      expect(summary.contains('Total Transactions: 12'), isTrue);
      expect(summary.contains('Food & Dining: ₹15,000 (100.0%)'), isTrue);
    });
  });
}
