import 'daily_report.dart';

class DaySpendTrend {
  final int day;
  final int amountMinor;

  const DaySpendTrend({required this.day, required this.amountMinor});
  double get amountDouble => amountMinor / 100.0;
}

class MonthComparison {
  final int currentMonthSpentMinor;
  final int previousMonthSpentMinor;
  final int differenceMinor; // positive = spent more, negative = spent less
  final double percentageChange; // e.g. +15.5% or -10.2%

  const MonthComparison({
    required this.currentMonthSpentMinor,
    required this.previousMonthSpentMinor,
    required this.differenceMinor,
    required this.percentageChange,
  });

  double get differenceDouble => differenceMinor / 100.0;
}

class MonthlyReport {
  final int year;
  final int month;
  final int monthlyBudgetMinor;
  final int totalSpentMinor;
  final int remainingBudgetMinor;
  final double utilizationPercent;
  final List<CategorySpending> categoryBreakdown;
  final List<DaySpendTrend> dailyTrends;
  final DaySpendTrend? highestSpendingDay;
  final int averageDailyExpensesMinor;
  final MonthComparison comparisonWithPreviousMonth;
  final int totalTransactionCount;

  const MonthlyReport({
    required this.year,
    required this.month,
    required this.monthlyBudgetMinor,
    required this.totalSpentMinor,
    required this.remainingBudgetMinor,
    required this.utilizationPercent,
    required this.categoryBreakdown,
    required this.dailyTrends,
    this.highestSpendingDay,
    required this.averageDailyExpensesMinor,
    required this.comparisonWithPreviousMonth,
    required this.totalTransactionCount,
  });

  double get monthlyBudgetDouble => monthlyBudgetMinor / 100.0;
  double get totalSpentDouble => totalSpentMinor / 100.0;
  double get remainingBudgetDouble => remainingBudgetMinor / 100.0;
  double get averageDailyExpensesDouble => averageDailyExpensesMinor / 100.0;
}
