import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/domain/services/budget_calculator.dart';

void main() {
  group('BudgetCalculator - Calendar & Days in Month', () {
    test('handles standard 31-day months', () {
      expect(BudgetCalculator.getDaysInMonth(2026, 1), 31); // January
      expect(BudgetCalculator.getDaysInMonth(2026, 3), 31); // March
      expect(BudgetCalculator.getDaysInMonth(2026, 5), 31); // May
      expect(BudgetCalculator.getDaysInMonth(2026, 7), 31); // July
      expect(BudgetCalculator.getDaysInMonth(2026, 8), 31); // August
      expect(BudgetCalculator.getDaysInMonth(2026, 10), 31); // October
      expect(BudgetCalculator.getDaysInMonth(2026, 12), 31); // December
    });

    test('handles standard 30-day months', () {
      expect(BudgetCalculator.getDaysInMonth(2026, 4), 30); // April
      expect(BudgetCalculator.getDaysInMonth(2026, 6), 30); // June
      expect(BudgetCalculator.getDaysInMonth(2026, 9), 30); // September
      expect(BudgetCalculator.getDaysInMonth(2026, 11), 30); // November
    });

    test('correctly handles February leap years and non-leap years', () {
      // 2024 is a leap year (29 days)
      expect(BudgetCalculator.isLeapYear(2024), isTrue);
      expect(BudgetCalculator.getDaysInMonth(2024, 2), 29);

      // 2025 is a non-leap year (28 days)
      expect(BudgetCalculator.isLeapYear(2025), isFalse);
      expect(BudgetCalculator.getDaysInMonth(2025, 2), 28);

      // 2026 is a non-leap year (28 days)
      expect(BudgetCalculator.isLeapYear(2026), isFalse);
      expect(BudgetCalculator.getDaysInMonth(2026, 2), 28);

      // 2028 is a leap year (29 days)
      expect(BudgetCalculator.isLeapYear(2028), isTrue);
      expect(BudgetCalculator.getDaysInMonth(2028, 2), 29);

      // Century non-leap year 1900
      expect(BudgetCalculator.isLeapYear(1900), isFalse);
      // Century leap year 2000
      expect(BudgetCalculator.isLeapYear(2000), isTrue);
    });
  });

  group('BudgetCalculator - Planned Daily Budget', () {
    test('calculates planned daily budget accurately for ₹30,000 (3,000,000 paise)', () {
      // For 30-day month: 3000000 / 30 = 100000 paise (₹1,000.00)
      final daily30 = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: 3000000,
        daysInMonth: 30,
      );
      expect(daily30, 100000);

      // For 31-day month: 3000000 / 31 = 96774 paise (~₹967.74)
      final daily31 = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: 3000000,
        daysInMonth: 31,
      );
      expect(daily31, 96774);

      // For 29-day month (Feb 2024 leap year): 3000000 / 29 = 103448 paise (~₹1,034.48)
      final daily29 = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: 3000000,
        daysInMonth: 29,
      );
      expect(daily29, 103448);

      // For 28-day month (Feb 2026): 3000000 / 28 = 107143 paise (~₹1,071.43)
      final daily28 = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: 3000000,
        daysInMonth: 28,
      );
      expect(daily28, 107143);
    });

    test('handles zero monthly budget gracefully', () {
      final daily = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: 0,
        daysInMonth: 30,
      );
      expect(daily, 0);
    });
  });

  group('BudgetCalculator - Remaining Monthly Budget & Overspending', () {
    test('calculates remaining monthly budget with zero expenses', () {
      final remaining = BudgetCalculator.calculateRemainingMonthlyBudget(
        monthlyBudgetMinor: 3000000,
        totalExpensesMinor: 0,
      );
      expect(remaining, 3000000);
      expect(
        BudgetCalculator.calculateOverspentAmount(
          monthlyBudgetMinor: 3000000,
          totalExpensesMinor: 0,
        ),
        0,
      );
    });

    test('handles expenses equal to monthly budget', () {
      final remaining = BudgetCalculator.calculateRemainingMonthlyBudget(
        monthlyBudgetMinor: 3000000,
        totalExpensesMinor: 3000000,
      );
      expect(remaining, 0);
      expect(
        BudgetCalculator.calculateOverspentAmount(
          monthlyBudgetMinor: 3000000,
          totalExpensesMinor: 3000000,
        ),
        0,
      );
      expect(
        BudgetCalculator.calculateUtilizationPercent(
          monthlyBudgetMinor: 3000000,
          totalExpensesMinor: 3000000,
        ),
        100.0,
      );
    });

    test('handles overspending without hiding original budget', () {
      const budget = 3000000; // ₹30,000
      const expenses = 3500000; // ₹35,000 (₹5,000 overspent)

      final remaining = BudgetCalculator.calculateRemainingMonthlyBudget(
        monthlyBudgetMinor: budget,
        totalExpensesMinor: expenses,
      );
      expect(remaining, -500000); // Negative ₹5,000

      final overspent = BudgetCalculator.calculateOverspentAmount(
        monthlyBudgetMinor: budget,
        totalExpensesMinor: expenses,
      );
      expect(overspent, 500000); // ₹5,000

      final utilization = BudgetCalculator.calculateUtilizationPercent(
        monthlyBudgetMinor: budget,
        totalExpensesMinor: expenses,
      );
      expect(utilization, closeTo(116.66, 0.1));
    });
  });

  group('BudgetCalculator - Safe-to-Spend Average Per Remaining Day', () {
    test('calculates safe to spend when halfway through 30-day month', () {
      // 15 days remaining, ₹15,000 remaining (1500000 paise)
      // 1500000 / 15 = 100000 paise (₹1,000/day)
      final avg = BudgetCalculator.calculateAverageAvailablePerRemainingDay(
        remainingMonthlyBudgetMinor: 1500000,
        remainingDaysInMonth: 15,
      );
      expect(avg, 100000);
    });

    test('returns 0 when remaining days is zero or negative', () {
      final avg = BudgetCalculator.calculateAverageAvailablePerRemainingDay(
        remainingMonthlyBudgetMinor: 1500000,
        remainingDaysInMonth: 0,
      );
      expect(avg, 0);
    });

    test('returns 0 when monthly budget is overspent', () {
      final avg = BudgetCalculator.calculateAverageAvailablePerRemainingDay(
        remainingMonthlyBudgetMinor: -500000,
        remainingDaysInMonth: 10,
      );
      expect(avg, 0);
    });
  });

  group('BudgetCalculator - Rollover logic', () {
    test('calculates rollover correctly when past days were under budget', () {
      // Planned daily budget: 100000 (₹1,000)
      // Day 1: spent 40000 (saved 60000)
      // Day 2: spent 50000 (saved 50000)
      // Day 3 (selected): accumulated rollover = 110000 (₹1,100)
      final past = {1: 40000, 2: 50000};
      final rollover = BudgetCalculator.calculateAccumulatedRollover(
        plannedDailyBudgetMinor: 100000,
        pastDayExpensesMinor: past,
        selectedDay: 3,
      );
      expect(rollover, 110000);
    });

    test('clamps negative accumulated rollover to 0', () {
      // Day 1: spent 200000 (over by 100000)
      // Day 2: spent 100000 (even)
      // Total net: -100000 -> rollover should be 0 (no carry-forward penalty from past overspending)
      final past = {1: 200000, 2: 100000};
      final rollover = BudgetCalculator.calculateAccumulatedRollover(
        plannedDailyBudgetMinor: 100000,
        pastDayExpensesMinor: past,
        selectedDay: 3,
      );
      expect(rollover, 0);
    });

    test('computes full budget with rollover disabled', () {
      final calc = BudgetCalculator.compute(
        monthlyBudgetMinor: 3000000,
        year: 2026,
        month: 11, // 30 days
        selectedDay: 15,
        totalMonthlyExpensesMinor: 1000000, // ₹10,000 spent so far
        totalSpentTodayMinor: 20000, // ₹200 spent today
        pastDayExpensesMinor: {1: 40000, 2: 50000},
        rolloverEnabled: false,
      );

      expect(calc.daysInMonth, 30);
      expect(calc.plannedDailyBudgetMinor, 100000); // ₹1,000
      expect(calc.rolloverAmountMinor, 0);
      expect(calc.recommendedAvailableTodayMinor, 100000); // ₹1,000
      expect(calc.totalSpentTodayMinor, 20000);
      expect(calc.remainingDailyAllowanceMinor, 80000); // ₹800 left today
      expect(calc.remainingMonthlyBudgetMinor, 2000000); // ₹20,000 left
      expect(calc.isOverspent, isFalse);
      expect(calc.isDailyOverspent, isFalse);
    });

    test('computes full budget with rollover enabled', () {
      final calc = BudgetCalculator.compute(
        monthlyBudgetMinor: 3000000,
        year: 2026,
        month: 11, // 30 days -> 100000 per day
        selectedDay: 3,
        totalMonthlyExpensesMinor: 90000,
        totalSpentTodayMinor: 30000,
        pastDayExpensesMinor: {1: 40000, 2: 50000}, // Day 1 saved 60000, Day 2 saved 50000 = 110000
        rolloverEnabled: true,
      );

      expect(calc.rolloverAmountMinor, 110000);
      // Today allowance: 100000 (planned) + 110000 (rollover) = 210000
      expect(calc.recommendedAvailableTodayMinor, 210000);
      // Remaining daily allowance: 210000 - 30000 = 180000
      expect(calc.remainingDailyAllowanceMinor, 180000);
      expect(calc.isDailyOverspent, isFalse);
    });
  });
}
