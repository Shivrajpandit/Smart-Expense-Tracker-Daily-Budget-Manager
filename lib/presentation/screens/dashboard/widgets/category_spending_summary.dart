import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/spendwise_card.dart';

class CategorySpendingSummary extends ConsumerWidget {
  const CategorySpendingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthExpenses = ref.watch(currentMonthExpensesProvider).value ?? [];
    final categoryMap = ref.watch(categoryMapProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    if (monthExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalSpentMinor = 0;
    final Map<String, int> catMap = {};
    for (final exp in monthExpenses) {
      totalSpentMinor += exp.amountMinor;
      catMap[exp.categoryId] = (catMap[exp.categoryId] ?? 0) + exp.amountMinor;
    }

    final sortedEntries = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedEntries.take(4).toList();

    return SpendWiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top Categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${catMap.length} categories',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topCategories.map((entry) {
            final cat = categoryMap[entry.key];
            final catName = cat?.name ?? 'Other';
            final catColor = cat?.color ?? AppColors.primary;
            final catIcon = cat?.iconData ?? Icons.category;
            final percent = totalSpentMinor > 0 ? (entry.value / totalSpentMinor) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(catIcon, size: 16, color: catColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          catName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.formatMinor(
                          entry.value,
                          symbol: currencySymbol,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 4,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
