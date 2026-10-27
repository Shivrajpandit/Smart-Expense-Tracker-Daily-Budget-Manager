import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/spendwise_card.dart';
import '../../../widgets/status_badge.dart';
import '../../settings/edit_budget_dialog.dart';

class MonthlyBudgetCard extends ConsumerWidget {
  const MonthlyBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(budgetCalculationProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isOverspent = calc.isOverspent;
    final progress = (calc.utilizationPercent / 100.0).clamp(0.0, 1.0);

    return SpendWiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.pie_chart_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Monthly Budget',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => EditBudgetDialog.show(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Total spent vs Monthly budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Spent',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatMinor(
                      calc.totalMonthlyExpensesMinor,
                      symbol: currencySymbol,
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isOverspent ? AppColors.danger : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Monthly Limit',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatMinor(
                      calc.monthlyBudgetMinor,
                      symbol: currencySymbol,
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverspent
                    ? AppColors.danger
                    : (progress > 0.8 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Progress percentage and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${calc.utilizationPercent.toStringAsFixed(1)}% utilized',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverspent ? AppColors.danger : AppColors.primary,
                ),
              ),
              if (isOverspent)
                Flexible(
                  child: StatusBadge(
                    label: 'Over: ${CurrencyFormatter.formatMinor(calc.overspentAmountMinor, symbol: currencySymbol)}',
                    color: AppColors.danger,
                    icon: Icons.error_outline,
                  ),
                )
              else
                Text(
                  '${CurrencyFormatter.formatMinor(calc.remainingMonthlyBudgetMinor, symbol: currencySymbol)} left',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),

          // Separate Planned Daily Budget vs Recommended Safe-to-Spend Per Remaining Day
          Row(
            children: [
              Expanded(
                child: _buildSubMetric(
                  context,
                  title: 'Planned Daily Budget',
                  subtitle: '${calc.daysInMonth} calendar days',
                  value: CurrencyFormatter.formatMinor(
                    calc.plannedDailyBudgetMinor,
                    symbol: currencySymbol,
                  ),
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: theme.dividerColor,
              ),
              Expanded(
                child: _buildSubMetric(
                  context,
                  title: 'Safe-to-Spend / Day',
                  subtitle: '${calc.remainingDaysInMonth} days remaining',
                  value: CurrencyFormatter.formatMinor(
                    calc.averageAvailablePerRemainingDayMinor,
                    symbol: currencySymbol,
                  ),
                  color: isOverspent ? AppColors.danger : AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodyMedium?.color?.withAlpha(160),
            ),
          ),
        ],
      ),
    );
  }
}
