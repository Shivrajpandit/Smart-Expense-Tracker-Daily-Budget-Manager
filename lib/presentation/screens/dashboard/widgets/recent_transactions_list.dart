import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/expense_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/spendwise_card.dart';
import '../../add_expense/add_expense_screen.dart';

class RecentTransactionsList extends ConsumerWidget {
  final VoidCallback? onSeeAll;

  const RecentTransactionsList({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentExpenses = ref.watch(recentExpensesStreamProvider).value ?? [];
    final categoryMap = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    if (recentExpenses.isEmpty) {
      return SpendWiseCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No transactions recorded yet',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the "+" button below to log your first expense',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Transactions',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SpendWiseCard(
          padding: const EdgeInsets.all(8),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentExpenses.length,
            separatorBuilder: (context, index) => const Divider(indent: 56),
            itemBuilder: (context, index) {
              final expense = recentExpenses[index];
              final category = categoryMap[expense.categoryId];
              final catColor = category?.color ?? AppColors.primary;
              final catIcon = category?.iconData ?? Icons.category;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(catIcon, color: catColor, size: 22),
                ),
                title: Text(
                  expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Row(
                  children: [
                    if (expense.merchant.isNotEmpty) ...[
                      Text(
                        expense.merchant,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const Text(' • '),
                    ],
                    Text(
                      DateFormatter.getRelativeDateString(expense.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        expense.paymentMethod,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '-${CurrencyFormatter.formatMinor(expense.amountMinor, symbol: currencySymbol)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.danger,
                  ),
                ),
                onTap: () => _showTransactionDetails(context, ref, expense),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTransactionDetails(BuildContext context, WidgetRef ref, ExpenseModel expense) {
    final category = ref.read(categoryMapProvider)[expense.categoryId];
    final currencySymbol = ref.read(currencySymbolProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                CurrencyFormatter.formatMinor(expense.amountMinor, symbol: currencySymbol),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _detailRow('Description', expense.description),
            if (expense.merchant.isNotEmpty) _detailRow('Merchant / Location', expense.merchant),
            _detailRow('Category', category?.name ?? 'Other'),
            _detailRow('Date & Time', '${DateFormatter.formatDate(expense.date)} at ${expense.timeString}'),
            _detailRow('Payment Method', expense.paymentMethod),
            if (expense.notes != null && expense.notes!.isNotEmpty)
              _detailRow('Notes', expense.notes!),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final confirmed = await ConfirmationDialog.show(
                        context: context,
                        title: 'Delete Expense',
                        message: 'Are you sure you want to delete this expense? This action will immediately update your budget and cannot be undone.',
                        confirmText: 'Delete',
                      );
                      if (confirmed) {
                        await ref.read(expenseRepositoryProvider).deleteExpense(expense.id);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      AddExpenseScreen.show(context, expenseToEdit: expense);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
