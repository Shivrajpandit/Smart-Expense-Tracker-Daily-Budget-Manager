import 'expense_model.dart';
import 'category_model.dart';

class CategorySpending {
  final CategoryModel category;
  final int totalAmountMinor;
  final int count;
  final double percentage; // 0 - 100

  const CategorySpending({
    required this.category,
    required this.totalAmountMinor,
    required this.count,
    required this.percentage,
  });

  double get totalAmountDouble => totalAmountMinor / 100.0;
}

class DailyReport {
  final DateTime date;
  final int dailyBudgetMinor;
  final int totalSpentMinor;
  final int remainingAllowanceMinor;
  final int expenseCount;
  final List<ExpenseModel> transactions;
  final List<CategorySpending> categoryBreakdown;
  final bool isOverspent;

  const DailyReport({
    required this.date,
    required this.dailyBudgetMinor,
    required this.totalSpentMinor,
    required this.remainingAllowanceMinor,
    required this.expenseCount,
    required this.transactions,
    required this.categoryBreakdown,
    required this.isOverspent,
  });

  double get dailyBudgetDouble => dailyBudgetMinor / 100.0;
  double get totalSpentDouble => totalSpentMinor / 100.0;
  double get remainingAllowanceDouble => remainingAllowanceMinor / 100.0;
}
