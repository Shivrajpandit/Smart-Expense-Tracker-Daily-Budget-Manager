import 'dart:math';
import '../models/budget_calculation.dart';

class BudgetCalculator {
  /// Returns actual number of calendar days in a given month and year,
  /// including leap year handling for February.
  static int getDaysInMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    // DateTime(year, month + 1, 0) gives the last day of the given month
    return DateTime(year, month + 1, 0).day;
  }

  /// Checks if a given year is a leap year.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Calculates planned daily budget = Monthly Budget / Days in Month
  static int calculatePlannedDailyBudget({
    required int monthlyBudgetMinor,
    required int daysInMonth,
  }) {
    if (daysInMonth <= 0 || monthlyBudgetMinor <= 0) return 0;
    return (monthlyBudgetMinor / daysInMonth).round();
  }

  /// Calculates remaining monthly budget = Monthly Budget - Total Expenses
  static int calculateRemainingMonthlyBudget({
    required int monthlyBudgetMinor,
    required int totalExpensesMinor,
  }) {
    return monthlyBudgetMinor - totalExpensesMinor;
  }

  /// Calculates overspent amount if expenses exceed monthly budget
  static int calculateOverspentAmount({
    required int monthlyBudgetMinor,
    required int totalExpensesMinor,
  }) {
    if (totalExpensesMinor > monthlyBudgetMinor) {
      return totalExpensesMinor - monthlyBudgetMinor;
    }
    return 0;
  }

  /// Calculates budget utilization percentage
  static double calculateUtilizationPercent({
    required int monthlyBudgetMinor,
    required int totalExpensesMinor,
  }) {
    if (monthlyBudgetMinor <= 0) {
      return totalExpensesMinor > 0 ? 100.0 : 0.0;
    }
    return (totalExpensesMinor / monthlyBudgetMinor) * 100.0;
  }

  /// Calculates remaining calendar days in month from a given day (inclusive)
  /// If [selectedDay] is 15 in a 31-day month, remaining days = 31 - 15 + 1 = 17 days
  static int calculateRemainingDays({
    required int daysInMonth,
    required int selectedDay,
  }) {
    if (selectedDay > daysInMonth) return 0;
    if (selectedDay < 1) return daysInMonth;
    return daysInMonth - selectedDay + 1;
  }

  /// Calculates indicative safe-to-spend average per remaining day:
  /// Average Available Per Remaining Day = Remaining Monthly Budget / Remaining Days in the Month
  static int calculateAverageAvailablePerRemainingDay({
    required int remainingMonthlyBudgetMinor,
    required int remainingDaysInMonth,
  }) {
    if (remainingDaysInMonth <= 0 || remainingMonthlyBudgetMinor <= 0) {
      return 0;
    }
    return (remainingMonthlyBudgetMinor / remainingDaysInMonth).round();
  }

  /// Calculates accumulated rollover from past days of the month.
  /// For each day from 1 to [selectedDay - 1]:
  ///   pastUnused = plannedDailyBudget - spentOnDay
  /// Returns the sum of unused allowances. If net is negative, returns 0.
  static int calculateAccumulatedRollover({
    required int plannedDailyBudgetMinor,
    required Map<int, int> pastDayExpensesMinor, // dayNumber -> spentMinor
    required int selectedDay,
  }) {
    if (selectedDay <= 1) return 0;

    int accumulated = 0;
    for (int day = 1; day < selectedDay; day++) {
      final spent = pastDayExpensesMinor[day] ?? 0;
      final diff = plannedDailyBudgetMinor - spent;
      accumulated += diff;
    }

    // Only positive accumulated budget can carry forward
    return max(0, accumulated);
  }

  /// Computes full budget calculation for a specific day and month
  static BudgetCalculation compute({
    required int monthlyBudgetMinor,
    required int year,
    required int month,
    required int selectedDay,
    required int totalMonthlyExpensesMinor,
    required int totalSpentTodayMinor,
    required Map<int, int> pastDayExpensesMinor,
    bool rolloverEnabled = false,
  }) {
    final daysInMonth = getDaysInMonth(year, month);
    final plannedDailyBudgetMinor = calculatePlannedDailyBudget(
      monthlyBudgetMinor: monthlyBudgetMinor,
      daysInMonth: daysInMonth,
    );

    final remainingMonthlyBudgetMinor = calculateRemainingMonthlyBudget(
      monthlyBudgetMinor: monthlyBudgetMinor,
      totalExpensesMinor: totalMonthlyExpensesMinor,
    );

    final overspentAmountMinor = calculateOverspentAmount(
      monthlyBudgetMinor: monthlyBudgetMinor,
      totalExpensesMinor: totalMonthlyExpensesMinor,
    );

    final utilizationPercent = calculateUtilizationPercent(
      monthlyBudgetMinor: monthlyBudgetMinor,
      totalExpensesMinor: totalMonthlyExpensesMinor,
    );

    final remainingDaysInMonth = calculateRemainingDays(
      daysInMonth: daysInMonth,
      selectedDay: selectedDay,
    );

    final averageAvailablePerRemainingDayMinor =
        calculateAverageAvailablePerRemainingDay(
      remainingMonthlyBudgetMinor: remainingMonthlyBudgetMinor,
      remainingDaysInMonth: remainingDaysInMonth,
    );

    int rolloverAmountMinor = 0;
    if (rolloverEnabled) {
      rolloverAmountMinor = calculateAccumulatedRollover(
        plannedDailyBudgetMinor: plannedDailyBudgetMinor,
        pastDayExpensesMinor: pastDayExpensesMinor,
        selectedDay: selectedDay,
      );
    }

    // Today's available allowance: planned daily budget + rollover (if enabled)
    final todayAllowanceMinor = plannedDailyBudgetMinor + rolloverAmountMinor;

    // Remaining daily allowance = today's allowance - spent today
    final remainingDailyAllowanceMinor = todayAllowanceMinor - totalSpentTodayMinor;

    final isOverspent = totalMonthlyExpensesMinor > monthlyBudgetMinor;
    final isDailyOverspent = totalSpentTodayMinor > todayAllowanceMinor;

    final dailyUtilizationPercent = todayAllowanceMinor > 0
        ? (totalSpentTodayMinor / todayAllowanceMinor) * 100.0
        : (totalSpentTodayMinor > 0 ? 100.0 : 0.0);

    return BudgetCalculation(
      monthlyBudgetMinor: monthlyBudgetMinor,
      plannedDailyBudgetMinor: plannedDailyBudgetMinor,
      recommendedAvailableTodayMinor: todayAllowanceMinor,
      totalSpentTodayMinor: totalSpentTodayMinor,
      remainingDailyAllowanceMinor: remainingDailyAllowanceMinor,
      totalMonthlyExpensesMinor: totalMonthlyExpensesMinor,
      remainingMonthlyBudgetMinor: remainingMonthlyBudgetMinor,
      overspentAmountMinor: overspentAmountMinor,
      utilizationPercent: utilizationPercent,
      daysInMonth: daysInMonth,
      remainingDaysInMonth: remainingDaysInMonth,
      averageAvailablePerRemainingDayMinor:
          averageAvailablePerRemainingDayMinor,
      isOverspent: isOverspent,
      isDailyOverspent: isDailyOverspent,
      rolloverAmountMinor: rolloverAmountMinor,
      dailyUtilizationPercent: dailyUtilizationPercent,
    );
  }
}
