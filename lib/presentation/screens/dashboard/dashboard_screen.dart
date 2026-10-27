import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/budget_provider.dart';
import '../add_expense/add_expense_screen.dart';
import 'widgets/budget_alert_banner.dart';
import 'widgets/category_spending_summary.dart';
import 'widgets/monthly_budget_card.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/today_pulse_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({super.key, this.onNavigateToHistory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthYear = ref.watch(selectedMonthYearProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SpendWise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Daily Budget Manager',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectMonthYear(context, ref),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.formatShortMonthYear(DateTime(monthYear.year, monthYear.month, 1)),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentMonthExpensesProvider);
          ref.invalidate(currentBudgetSettingsProvider);
          ref.invalidate(selectedDateExpensesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active budget alert banner if threshold reached or exceeded
              const BudgetAlertBanner(),

              // Hero Today Pulse Card
              const TodayPulseCard(),
              const SizedBox(height: 16),

              // Monthly Budget Card
              const MonthlyBudgetCard(),
              const SizedBox(height: 16),

              // Category Spending Summary
              const CategorySpendingSummary(),
              const SizedBox(height: 16),

              // Recent Transactions
              RecentTransactionsList(onSeeAll: onNavigateToHistory),
              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => AddExpenseScreen.show(context),
      ),
    );
  }

  Future<void> _selectMonthYear(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedMonthYearProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      ref.read(selectedMonthYearProvider.notifier).state =
          MonthYear(year: picked.year, month: picked.month);
      // Also update selected date to same month if out of bounds
      final selDate = ref.read(selectedDateProvider);
      if (selDate.month != picked.month || selDate.year != picked.year) {
        ref.read(selectedDateProvider.notifier).state = DateTime(picked.year, picked.month, 1);
      }
    }
  }
}
