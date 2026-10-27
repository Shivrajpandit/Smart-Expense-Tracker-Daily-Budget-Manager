import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/export_helper.dart';
import '../../../domain/models/expense_model.dart';
import '../../../domain/models/filter_options.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/spendwise_card.dart';
import '../add_expense/add_expense_screen.dart';
import 'transaction_filter_sheet.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final categoryMap = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final filter = ref.watch(transactionFilterProvider);
    final theme = Theme.of(context);

    // Group expenses by date string
    final Map<String, List<ExpenseModel>> grouped = {};
    for (final exp in filteredExpenses) {
      final key = DateFormatter.getRelativeDateString(exp.date);
      grouped.putIfAbsent(key, () => []).add(exp);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: () => _exportCsv(context, filteredExpenses),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => TransactionFilterSheet.show(context),
              ),
              if (filter.hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search merchant, description, notes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(transactionFilterProvider.notifier).state =
                              filter.copyWith(searchQuery: '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(transactionFilterProvider.notifier).state =
                    filter.copyWith(searchQuery: val);
              },
            ),
          ),

          // Total matching count and sum
          if (filteredExpenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredExpenses.length} transactions found',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Total: ${CurrencyFormatter.formatMinor(_calcTotal(filteredExpenses), symbol: currencySymbol)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredExpenses.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No transactions found',
                    description: filter.hasActiveFilters
                        ? 'Try modifying your search or clearing active filters.'
                        : 'You haven\'t logged any expenses yet.',
                    buttonText: filter.hasActiveFilters ? 'Clear Filters' : 'Add Expense',
                    onButtonPressed: () {
                      if (filter.hasActiveFilters) {
                        _searchController.clear();
                        ref.read(transactionFilterProvider.notifier).state =
                            TransactionFilterOptions();
                      } else {
                        AddExpenseScreen.show(context);
                      }
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, groupIndex) {
                      final dateHeader = grouped.keys.elementAt(groupIndex);
                      final items = grouped[dateHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 6, left: 4),
                            child: Text(
                              dateHeader,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          SpendWiseCard(
                            padding: const EdgeInsets.all(4),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) => const Divider(indent: 56),
                              itemBuilder: (context, itemIndex) {
                                final exp = items[itemIndex];
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
                  ),
          ),
        ],
      ),
    );
  }

  int _calcTotal(List<ExpenseModel> list) {
    int total = 0;
    for (final e in list) {
      total += e.amountMinor;
    }
    return total;
  }

  void _exportCsv(BuildContext context, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    final categories = ref.read(categoryMapProvider);
    final currencySymbol = ref.read(currencySymbolProvider);
    final csvContent = ExportHelper.exportTransactionsToCsv(
      expenses: expenses,
      categories: categories,
      currencySymbol: currencySymbol,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exported CSV Data', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
