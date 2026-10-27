enum TransactionSortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

enum TransactionTypeFilter {
  all,
  expensesOnly,
  incomeOnly,
}

class TransactionFilterOptions {
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> categoryIds;
  final List<String> paymentMethods;
  final TransactionTypeFilter typeFilter;
  final TransactionSortOption sortOption;

  const TransactionFilterOptions({
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.categoryIds = const [],
    this.paymentMethods = const [],
    this.typeFilter = TransactionTypeFilter.all,
    this.sortOption = TransactionSortOption.dateDesc,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      categoryIds.isNotEmpty ||
      paymentMethods.isNotEmpty ||
      typeFilter != TransactionTypeFilter.all ||
      sortOption != TransactionSortOption.dateDesc;

  TransactionFilterOptions copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
    List<String>? paymentMethods,
    TransactionTypeFilter? typeFilter,
    TransactionSortOption? sortOption,
    bool clearDates = false,
  }) {
    return TransactionFilterOptions(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      categoryIds: categoryIds ?? this.categoryIds,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      typeFilter: typeFilter ?? this.typeFilter,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
