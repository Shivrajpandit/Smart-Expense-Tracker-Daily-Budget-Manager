import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/filter_options.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const TransactionFilterSheet(),
    );
  }

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  late TransactionSortOption _sortOption;
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedPaymentMethods = {};

  @override
  void initState() {
    super.initState();
    final filter = ref.read(transactionFilterProvider);
    _sortOption = filter.sortOption;
    _startDate = filter.startDate;
    _endDate = filter.endDate;
    _selectedCategories.addAll(filter.categoryIds);
    _selectedPaymentMethods.addAll(filter.paymentMethods);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort Transactions',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortOption = TransactionSortOption.dateDesc;
                    _startDate = null;
                    _endDate = null;
                    _selectedCategories.clear();
                    _selectedPaymentMethods.clear();
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sortChip('Newest First', TransactionSortOption.dateDesc),
                      _sortChip('Oldest First', TransactionSortOption.dateAsc),
                      _sortChip('Highest Amount', TransactionSortOption.amountDesc),
                      _sortChip('Lowest Amount', TransactionSortOption.amountAsc),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Range
                  Text(
                    'Date Range',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            _startDate != null ? DateFormatter.formatDate(_startDate!) : 'Start Date',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) setState(() => _startDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(
                            _endDate != null ? DateFormatter.formatDate(_endDate!) : 'End Date',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) setState(() => _endDate = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Categories
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    data: (cats) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cats.map((cat) {
                        final isSelected = _selectedCategories.contains(cat.id);
                        return FilterChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(cat.id);
                              } else {
                                _selectedCategories.remove(cat.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Payment Methods
                  Text(
                    'Payment Methods',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.paymentMethods.map((method) {
                      final isSelected = _selectedPaymentMethods.contains(method);
                      return FilterChip(
                        label: Text(method),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPaymentMethods.add(method);
                            } else {
                              _selectedPaymentMethods.remove(method);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final current = ref.read(transactionFilterProvider);
                ref.read(transactionFilterProvider.notifier).state = current.copyWith(
                  sortOption: _sortOption,
                  startDate: _startDate,
                  endDate: _endDate,
                  categoryIds: _selectedCategories.toList(),
                  paymentMethods: _selectedPaymentMethods.toList(),
                  clearDates: _startDate == null && _endDate == null,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, TransactionSortOption option) {
    final isSelected = _sortOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _sortOption = option);
      },
    );
  }
}
