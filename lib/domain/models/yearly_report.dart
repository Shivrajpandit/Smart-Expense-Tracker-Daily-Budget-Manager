import 'daily_report.dart';

class MonthSpendSummary {
  final int month; // 1-12
  final String monthName;
  final int totalExpenseMinor;
  final int totalIncomeMinor;
  final int budgetMinor;
  final double utilizationPercent;

  const MonthSpendSummary({
    required this.month,
    required this.monthName,
    required this.totalExpenseMinor,
    required this.totalIncomeMinor,
    required this.budgetMinor,
    required this.utilizationPercent,
  });

  double get totalExpenseDouble => totalExpenseMinor / 100.0;
  double get totalIncomeDouble => totalIncomeMinor / 100.0;
}

class YearlyReport {
  final int year;
  final int totalExpensesMinor;
  final int totalIncomeMinor;
  final int netSavingsMinor;
  final List<MonthSpendSummary> monthlySummaries; // 12 items
  final List<CategorySpending> categoryBreakdown;
  final int averageMonthlyExpenditureMinor;
  final MonthSpendSummary? highestSpendingMonth;
  final MonthSpendSummary? lowestSpendingMonth;
  final double overallBudgetUtilization;

  const YearlyReport({
    required this.year,
    required this.totalExpensesMinor,
    required this.totalIncomeMinor,
    required this.netSavingsMinor,
    required this.monthlySummaries,
    required this.categoryBreakdown,
    required this.averageMonthlyExpenditureMinor,
    this.highestSpendingMonth,
    this.lowestSpendingMonth,
    required this.overallBudgetUtilization,
  });

  double get totalExpensesDouble => totalExpensesMinor / 100.0;
  double get totalIncomeDouble => totalIncomeMinor / 100.0;
  double get netSavingsDouble => netSavingsMinor / 100.0;
  double get averageMonthlyExpenditureDouble =>
      averageMonthlyExpenditureMinor / 100.0;
}
