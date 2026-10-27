class BudgetCalculation {
  final int monthlyBudgetMinor;
  final int plannedDailyBudgetMinor;
  final int recommendedAvailableTodayMinor;
  final int totalSpentTodayMinor;
  final int remainingDailyAllowanceMinor;
  final int totalMonthlyExpensesMinor;
  final int remainingMonthlyBudgetMinor;
  final int overspentAmountMinor;
  final double utilizationPercent;
  final int daysInMonth;
  final int remainingDaysInMonth;
  final int averageAvailablePerRemainingDayMinor;
  final bool isOverspent;
  final bool isDailyOverspent;
  final int rolloverAmountMinor;
  final double dailyUtilizationPercent;

  const BudgetCalculation({
    required this.monthlyBudgetMinor,
    required this.plannedDailyBudgetMinor,
    required this.recommendedAvailableTodayMinor,
    required this.totalSpentTodayMinor,
    required this.remainingDailyAllowanceMinor,
    required this.totalMonthlyExpensesMinor,
    required this.remainingMonthlyBudgetMinor,
    required this.overspentAmountMinor,
    required this.utilizationPercent,
    required this.daysInMonth,
    required this.remainingDaysInMonth,
    required this.averageAvailablePerRemainingDayMinor,
    required this.isOverspent,
    required this.isDailyOverspent,
    required this.rolloverAmountMinor,
    required this.dailyUtilizationPercent,
  });

  double get monthlyBudgetDouble => monthlyBudgetMinor / 100.0;
  double get plannedDailyBudgetDouble => plannedDailyBudgetMinor / 100.0;
  double get recommendedAvailableTodayDouble => recommendedAvailableTodayMinor / 100.0;
  double get totalSpentTodayDouble => totalSpentTodayMinor / 100.0;
  double get remainingDailyAllowanceDouble => remainingDailyAllowanceMinor / 100.0;
  double get totalMonthlyExpensesDouble => totalMonthlyExpensesMinor / 100.0;
  double get remainingMonthlyBudgetDouble => remainingMonthlyBudgetMinor / 100.0;
  double get overspentAmountDouble => overspentAmountMinor / 100.0;
  double get averageAvailablePerRemainingDayDouble =>
      averageAvailablePerRemainingDayMinor / 100.0;
}
