import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/spendwise_card.dart';
import '../../widgets/status_badge.dart';
import '../add_expense/add_expense_screen.dart';

class DailyTrackingScreen extends ConsumerWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dailyReportAsync = ref.watch(dailyReportProvider(selectedDate));
    final categoryMap = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Spending',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: 'Go to Today',
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date navigator header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  },
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickDate(context, ref, selectedDate),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              DateFormatter.getRelativeDateString(selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              DateFormatter.formatDate(selectedDate),
                              style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: dailyReportAsync.when(
              data: (report) {
                final isOver = report.isOverspent;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Daily Metrics Hero Card
                    SpendWiseCard(
                      gradient: LinearGradient(
                        colors: isOver ? AppColors.dangerGradient : AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isOver ? 'Allowance Exceeded' : 'Remaining Allowance',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              StatusBadge(
                                label: isOver ? 'Overspent' : 'Within Budget',
                                color: isOver ? Colors.white : AppColors.success,
                                isFilled: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.formatMinor(
                              report.remainingAllowanceMinor.abs(),
                              symbol: currencySymbol,
                            ),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _whiteMetric('Daily Budget', CurrencyFormatter.formatMinor(report.dailyBudgetMinor, symbol: currencySymbol)),
                              _whiteMetric('Total Spent', CurrencyFormatter.formatMinor(report.totalSpentMinor, symbol: currencySymbol)),
                              _whiteMetric('Transactions', '${report.expenseCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Breakdown for the day
                    if (report.categoryBreakdown.isNotEmpty) ...[
                      Text(
                        'Category Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      SpendWiseCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: report.categoryBreakdown.map((catSpend) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: catSpend.category.color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(catSpend.category.iconData, color: catSpend.category.color, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      catSpend.category.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    '${catSpend.percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    CurrencyFormatter.formatMinor(catSpend.totalAmountMinor, symbol: currencySymbol),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Transactions for this day
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions (${report.expenseCount})',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: () => AddExpenseScreen.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (report.transactions.isEmpty)
                      EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No expenses on this date',
                        description: 'You haven\'t logged any spending for ${DateFormatter.formatDate(selectedDate)}.',
                        buttonText: 'Add Expense',
                        onButtonPressed: () => AddExpenseScreen.show(context),
                      )
                    else
                      SpendWiseCard(
                        padding: const EdgeInsets.all(8),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.transactions.length,
                          separatorBuilder: (context, index) => const Divider(indent: 56),
                          itemBuilder: (context, index) {
                            final exp = report.transactions[index];
                            final cat = categoryMap[exp.categoryId];
                            final catColor = cat?.color ?? AppColors.primary;
                            final catIcon = cat?.iconData ?? Icons.category;

                            return Dismissible(
                              key: Key(exp.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) => ConfirmationDialog.show(
                                context: context,
                                title: 'Delete Expense',
                                message: 'Are you sure you want to delete this expense?',
                              ),
                              onDismissed: (_) {
                                ref.read(expenseRepositoryProvider).deleteExpense(exp.id);
                                ref.invalidate(dailyReportProvider(selectedDate));
                              },
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: catColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(catIcon, color: catColor, size: 20),
                                ),
                                title: Text(
                                  exp.description,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${exp.timeString} • ${exp.paymentMethod}${exp.merchant.isNotEmpty ? ' • ${exp.merchant}' : ''}',
                                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                                ),
                                trailing: Text(
                                  '-${CurrencyFormatter.formatMinor(exp.amountMinor, symbol: currencySymbol)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.danger,
                                  ),
                                ),
                                onTap: () => AddExpenseScreen.show(context, expenseToEdit: exp),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
}
