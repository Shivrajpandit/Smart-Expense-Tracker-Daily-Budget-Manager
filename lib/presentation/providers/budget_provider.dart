import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/budget_calculation.dart';
import '../../domain/models/budget_settings_model.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/services/budget_calculator.dart';
import 'database_provider.dart';

class MonthYear {
  final int year;
  final int month;

  const MonthYear({required this.year, required this.month});

  MonthYear copyWith({int? year, int? month}) {
    return MonthYear(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthYear &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

class SelectedMonthYearNotifier extends Notifier<MonthYear> {
  @override
  MonthYear build() {
    final now = DateTime.now();
    return MonthYear(year: now.year, month: now.month);
  }

  @override
  set state(MonthYear value) => super.state = value;
}

final selectedMonthYearProvider =
    NotifierProvider<SelectedMonthYearNotifier, MonthYear>(SelectedMonthYearNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  @override
  set state(DateTime value) => super.state = value;
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final currentBudgetSettingsProvider = StreamProvider<BudgetSettingsModel>((ref) {
  final monthYear = ref.watch(selectedMonthYearProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetForMonth(monthYear.year, monthYear.month);
});

final currentMonthExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final monthYear = ref.watch(selectedMonthYearProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchExpensesForMonth(monthYear.year, monthYear.month);
});

final selectedDateExpensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchExpensesForDate(date);
});

/// Automatically recalculates all budget metrics reactively whenever
/// an expense is added, edited, or deleted, or when the month/date changes.
final budgetCalculationProvider = Provider<BudgetCalculation>((ref) {
  final monthYear = ref.watch(selectedMonthYearProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final budgetSettingsAsync = ref.watch(currentBudgetSettingsProvider);
  final monthExpensesAsync = ref.watch(currentMonthExpensesProvider);

  final budgetSettings = budgetSettingsAsync.value;
  final monthExpenses = monthExpensesAsync.value ?? [];

  final monthlyBudgetMinor = budgetSettings?.monthlyBudgetMinor ?? 3000000;
  final rolloverEnabled = budgetSettings?.rolloverEnabled ?? false;

  // Aggregate expenses per day of month
  final Map<int, int> dayExpenses = {};
  int totalMonthlyExpensesMinor = 0;
  int totalSpentTodayMinor = 0;

  for (final exp in monthExpenses) {
    final day = exp.date.day;
    dayExpenses[day] = (dayExpenses[day] ?? 0) + exp.amountMinor;
    totalMonthlyExpensesMinor += exp.amountMinor;

    // Check if on selected date
    if (exp.date.year == selectedDate.year &&
        exp.date.month == selectedDate.month &&
        exp.date.day == selectedDate.day) {
      totalSpentTodayMinor += exp.amountMinor;
    }
  }

  return BudgetCalculator.compute(
    monthlyBudgetMinor: monthlyBudgetMinor,
    year: monthYear.year,
    month: monthYear.month,
    selectedDay: selectedDate.day,
    totalMonthlyExpensesMinor: totalMonthlyExpensesMinor,
    totalSpentTodayMinor: totalSpentTodayMinor,
    pastDayExpensesMinor: dayExpenses,
    rolloverEnabled: rolloverEnabled,
  );
});
