import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/daily_report.dart';
import '../../domain/models/monthly_report.dart';
import '../../domain/models/yearly_report.dart';
import '../../domain/services/budget_calculator.dart';
import 'budget_provider.dart';
import 'category_provider.dart';
import 'database_provider.dart';

final dailyReportProvider = StreamProvider.family<DailyReport, DateTime>((ref, rawDate) {
  final date = DateTime(rawDate.year, rawDate.month, rawDate.day);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final categoryMap = ref.watch(categoryMapProvider);

  return expenseRepo.watchExpensesForDate(date).asyncMap((expenses) async {
    final budgetSettings = await budgetRepo.getBudgetForMonth(date.year, date.month);

    final daysInMonth = BudgetCalculator.getDaysInMonth(date.year, date.month);
    final dailyBudgetMinor = BudgetCalculator.calculatePlannedDailyBudget(
      monthlyBudgetMinor: budgetSettings.monthlyBudgetMinor,
      daysInMonth: daysInMonth,
    );

    int totalSpentMinor = 0;
    final Map<String, int> catAmounts = {};
    final Map<String, int> catCounts = {};

    for (final e in expenses) {
      totalSpentMinor += e.amountMinor;
      catAmounts[e.categoryId] = (catAmounts[e.categoryId] ?? 0) + e.amountMinor;
      catCounts[e.categoryId] = (catCounts[e.categoryId] ?? 0) + 1;
    }

    final List<CategorySpending> breakdown = [];
    catAmounts.forEach((catId, amount) {
      final cat = categoryMap[catId] ??
          CategoryModel(
            id: catId,
            name: 'Other',
            iconCodePoint: 0xe148,
            colorValue: 0xFF78909C,
          );
      final pct = totalSpentMinor > 0 ? (amount / totalSpentMinor) * 100 : 0.0;
      breakdown.add(CategorySpending(
        category: cat,
        totalAmountMinor: amount,
        count: catCounts[catId] ?? 1,
        percentage: pct,
      ));
    });
    breakdown.sort((a, b) => b.totalAmountMinor.compareTo(a.totalAmountMinor));

    return DailyReport(
      date: date,
      dailyBudgetMinor: dailyBudgetMinor,
      totalSpentMinor: totalSpentMinor,
      remainingAllowanceMinor: dailyBudgetMinor - totalSpentMinor,
      expenseCount: expenses.length,
      transactions: expenses,
      categoryBreakdown: breakdown,
      isOverspent: totalSpentMinor > dailyBudgetMinor,
    );
  });
});

final monthlyReportProvider = StreamProvider.family<MonthlyReport, MonthYear>((ref, my) {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final categoryMap = ref.watch(categoryMapProvider);

  return expenseRepo.watchExpensesForMonth(my.year, my.month).asyncMap((currentExpenses) async {
    final budgetSettings = await budgetRepo.getBudgetForMonth(my.year, my.month);

    // Previous month calculation
    final prevYear = my.month == 1 ? my.year - 1 : my.year;
    final prevMonth = my.month == 1 ? 12 : my.month - 1;
    final prevExpenses = await expenseRepo.getExpensesForMonth(prevYear, prevMonth);

    int prevMonthTotalMinor = 0;
    for (final e in prevExpenses) {
      prevMonthTotalMinor += e.amountMinor;
    }

    int totalSpentMinor = 0;
    final Map<String, int> catAmounts = {};
    final Map<String, int> catCounts = {};
    final Map<int, int> dayAmounts = {};

    final daysInMonth = BudgetCalculator.getDaysInMonth(my.year, my.month);

    for (final e in currentExpenses) {
      totalSpentMinor += e.amountMinor;
      catAmounts[e.categoryId] = (catAmounts[e.categoryId] ?? 0) + e.amountMinor;
      catCounts[e.categoryId] = (catCounts[e.categoryId] ?? 0) + 1;
      dayAmounts[e.date.day] = (dayAmounts[e.date.day] ?? 0) + e.amountMinor;
    }

    // Category breakdown
    final List<CategorySpending> breakdown = [];
    catAmounts.forEach((catId, amount) {
      final cat = categoryMap[catId] ??
          CategoryModel(
            id: catId,
            name: 'Other',
            iconCodePoint: 0xe148,
            colorValue: 0xFF78909C,
          );
      final pct = totalSpentMinor > 0 ? (amount / totalSpentMinor) * 100 : 0.0;
      breakdown.add(CategorySpending(
        category: cat,
        totalAmountMinor: amount,
        count: catCounts[catId] ?? 1,
        percentage: pct,
      ));
    });
    breakdown.sort((a, b) => b.totalAmountMinor.compareTo(a.totalAmountMinor));

    // Daily trends for all days in month
    final List<DaySpendTrend> trends = [];
    DaySpendTrend? highestDay;
    int highestAmount = -1;

    for (int d = 1; d <= daysInMonth; d++) {
      final amt = dayAmounts[d] ?? 0;
      final trend = DaySpendTrend(day: d, amountMinor: amt);
      trends.add(trend);
      if (amt > highestAmount) {
        highestAmount = amt;
        highestDay = trend;
      }
    }

    final remainingBudgetMinor = budgetSettings.monthlyBudgetMinor - totalSpentMinor;
    final utilizationPercent = budgetSettings.monthlyBudgetMinor > 0
        ? (totalSpentMinor / budgetSettings.monthlyBudgetMinor) * 100
        : 0.0;

    final avgDailyMinor = daysInMonth > 0 ? (totalSpentMinor / daysInMonth).round() : 0;

    // Comparison with previous month
    final diffMinor = totalSpentMinor - prevMonthTotalMinor;
    final pctChange = prevMonthTotalMinor > 0
        ? (diffMinor / prevMonthTotalMinor) * 100
        : (totalSpentMinor > 0 ? 100.0 : 0.0);

    final comparison = MonthComparison(
      currentMonthSpentMinor: totalSpentMinor,
      previousMonthSpentMinor: prevMonthTotalMinor,
      differenceMinor: diffMinor,
      percentageChange: pctChange,
    );

    return MonthlyReport(
      year: my.year,
      month: my.month,
      monthlyBudgetMinor: budgetSettings.monthlyBudgetMinor,
      totalSpentMinor: totalSpentMinor,
      remainingBudgetMinor: remainingBudgetMinor,
      utilizationPercent: utilizationPercent,
      categoryBreakdown: breakdown,
      dailyTrends: trends,
      highestSpendingDay: highestAmount > 0 ? highestDay : null,
      averageDailyExpensesMinor: avgDailyMinor,
      comparisonWithPreviousMonth: comparison,
      totalTransactionCount: currentExpenses.length,
    );
  });
});

final yearlyReportProvider = StreamProvider.family<YearlyReport, int>((ref, year) {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final incomeRepo = ref.watch(incomeRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final categoryMap = ref.watch(categoryMapProvider);

  return expenseRepo.watchExpensesForYear(year).asyncMap((yearExpenses) async {
    final yearIncomes = await incomeRepo.getIncomesForYear(year);

    int totalExpensesMinor = 0;
    final Map<int, int> monthExpenses = {};
    final Map<int, int> monthIncomes = {};
    final Map<String, int> catAmounts = {};
    final Map<String, int> catCounts = {};

    for (final e in yearExpenses) {
      totalExpensesMinor += e.amountMinor;
      monthExpenses[e.date.month] = (monthExpenses[e.date.month] ?? 0) + e.amountMinor;
      catAmounts[e.categoryId] = (catAmounts[e.categoryId] ?? 0) + e.amountMinor;
      catCounts[e.categoryId] = (catCounts[e.categoryId] ?? 0) + 1;
    }

    int totalIncomeMinor = 0;
    for (final inc in yearIncomes) {
      totalIncomeMinor += inc.amountMinor;
      monthIncomes[inc.date.month] = (monthIncomes[inc.date.month] ?? 0) + inc.amountMinor;
    }

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final List<MonthSpendSummary> summaries = [];
    MonthSpendSummary? highestMonth;
    MonthSpendSummary? lowestMonth;
    int maxExpense = -1;
    int minExpense = 9999999999;
    int totalBudgetsMinor = 0;

    for (int m = 1; m <= 12; m++) {
      final budget = await budgetRepo.getBudgetForMonth(year, m);
      totalBudgetsMinor += budget.monthlyBudgetMinor;

      final exp = monthExpenses[m] ?? 0;
      final inc = monthIncomes[m] ?? 0;
      final util = budget.monthlyBudgetMinor > 0 ? (exp / budget.monthlyBudgetMinor) * 100 : 0.0;

      final summary = MonthSpendSummary(
        month: m,
        monthName: monthNames[m - 1],
        totalExpenseMinor: exp,
        totalIncomeMinor: inc,
        budgetMinor: budget.monthlyBudgetMinor,
        utilizationPercent: util,
      );
      summaries.add(summary);

      if (exp > maxExpense) {
        maxExpense = exp;
        highestMonth = summary;
      }
      if (exp < minExpense && exp > 0) {
        minExpense = exp;
        lowestMonth = summary;
      }
    }

    // Category breakdown
    final List<CategorySpending> breakdown = [];
    catAmounts.forEach((catId, amount) {
      final cat = categoryMap[catId] ??
          CategoryModel(
            id: catId,
            name: 'Other',
            iconCodePoint: 0xe148,
            colorValue: 0xFF78909C,
          );
      final pct = totalExpensesMinor > 0 ? (amount / totalExpensesMinor) * 100 : 0.0;
      breakdown.add(CategorySpending(
        category: cat,
        totalAmountMinor: amount,
        count: catCounts[catId] ?? 1,
        percentage: pct,
      ));
    });
    breakdown.sort((a, b) => b.totalAmountMinor.compareTo(a.totalAmountMinor));

    final avgMonthlyMinor = (totalExpensesMinor / 12).round();
    final overallUtil = totalBudgetsMinor > 0 ? (totalExpensesMinor / totalBudgetsMinor) * 100 : 0.0;

    return YearlyReport(
      year: year,
      totalExpensesMinor: totalExpensesMinor,
      totalIncomeMinor: totalIncomeMinor,
      netSavingsMinor: totalIncomeMinor - totalExpensesMinor,
      monthlySummaries: summaries,
      categoryBreakdown: breakdown,
      averageMonthlyExpenditureMinor: avgMonthlyMinor,
      highestSpendingMonth: maxExpense > 0 ? highestMonth : null,
      lowestSpendingMonth: minExpense < 9999999999 ? lowestMonth : null,
      overallBudgetUtilization: overallUtil,
    );
  });
});
