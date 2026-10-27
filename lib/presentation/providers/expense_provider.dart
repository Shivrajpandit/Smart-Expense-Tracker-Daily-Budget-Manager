import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/filter_options.dart';
import 'database_provider.dart';

final recentExpensesStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchRecentExpenses(limit: 5);
});

final allExpensesStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchAllExpenses();
});

class TransactionFilterNotifier extends Notifier<TransactionFilterOptions> {
  @override
  TransactionFilterOptions build() => const TransactionFilterOptions();

  @override
  set state(TransactionFilterOptions value) => super.state = value;
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterOptions>(TransactionFilterNotifier.new);

/// Watches all expenses and applies filters & sorting
final filteredExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final allAsync = ref.watch(allExpensesStreamProvider);
  final filter = ref.watch(transactionFilterProvider);

  final list = allAsync.value ?? [];
  var result = List<ExpenseModel>.from(list);

  // Date range filter
  if (filter.startDate != null) {
    final start = DateTime(
      filter.startDate!.year,
      filter.startDate!.month,
      filter.startDate!.day,
    );
    result = result.where((e) => e.date.isAfter(start) || e.date.isAtSameMomentAs(start)).toList();
  }

  if (filter.endDate != null) {
    final end = DateTime(
      filter.endDate!.year,
      filter.endDate!.month,
      filter.endDate!.day,
      23,
      59,
      59,
      999,
    );
    result = result.where((e) => e.date.isBefore(end) || e.date.isAtSameMomentAs(end)).toList();
  }

  // Category filter
  if (filter.categoryIds.isNotEmpty) {
    result = result.where((e) => filter.categoryIds.contains(e.categoryId)).toList();
  }

  // Payment method filter
  if (filter.paymentMethods.isNotEmpty) {
    result = result.where((e) => filter.paymentMethods.contains(e.paymentMethod)).toList();
  }

  // Search query filter
  if (filter.searchQuery.trim().isNotEmpty) {
    final q = filter.searchQuery.trim().toLowerCase();
    result = result.where((e) {
      final descMatch = e.description.toLowerCase().contains(q);
      final merchMatch = e.merchant.toLowerCase().contains(q);
      final notesMatch = e.notes?.toLowerCase().contains(q) ?? false;
      return descMatch || merchMatch || notesMatch;
    }).toList();
  }

  // Sorting
  switch (filter.sortOption) {
    case TransactionSortOption.dateDesc:
      result.sort((a, b) => b.date.compareTo(a.date));
      break;
    case TransactionSortOption.dateAsc:
      result.sort((a, b) => a.date.compareTo(b.date));
      break;
    case TransactionSortOption.amountDesc:
      result.sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
      break;
    case TransactionSortOption.amountAsc:
      result.sort((a, b) => a.amountMinor.compareTo(b.amountMinor));
      break;
  }

  return result;
});
