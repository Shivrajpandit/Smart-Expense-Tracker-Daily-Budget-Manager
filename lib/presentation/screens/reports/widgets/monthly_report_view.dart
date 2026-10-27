import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/monthly_report.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/reports_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/spendwise_card.dart';

class MonthlyReportView extends ConsumerWidget {
  const MonthlyReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthYear = ref.watch(selectedMonthYearProvider);
    final reportAsync = ref.watch(monthlyReportProvider(monthYear));
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return reportAsync.when(
      data: (report) {
        if (report.totalTransactionCount == 0) {
          return EmptyStateView(
            icon: Icons.bar_chart_outlined,
            title: 'No Data for ${DateFormatter.formatMonthYear(DateTime(monthYear.year, monthYear.month, 1))}',
            description: 'There are no recorded expenses for this month yet.',
          );
        }

        final comp = report.comparisonWithPreviousMonth;
        final isSpentMore = comp.differenceMinor > 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Spent',
                    value: CurrencyFormatter.formatMinor(report.totalSpentMinor, symbol: currencySymbol),
                    subtitle: '${report.utilizationPercent.toStringAsFixed(1)}% of budget',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Remaining Budget',
                    value: CurrencyFormatter.formatMinor(report.remainingBudgetMinor.abs(), symbol: currencySymbol),
                    subtitle: report.remainingBudgetMinor < 0 ? 'Overspent' : 'Safe Balance',
                    color: report.remainingBudgetMinor < 0 ? AppColors.danger : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Daily Average',
                    value: CurrencyFormatter.formatMinor(report.averageDailyExpensesMinor, symbol: currencySymbol),
                    subtitle: 'Across calendar days',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Peak Spending Day',
                    value: report.highestSpendingDay != null
                        ? 'Day ${report.highestSpendingDay!.day}'
                        : 'N/A',
                    subtitle: report.highestSpendingDay != null
                        ? CurrencyFormatter.formatMinor(report.highestSpendingDay!.amountMinor, symbol: currencySymbol)
                        : 'No expenses',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Month-over-month comparison card
            SpendWiseCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isSpentMore ? AppColors.danger : AppColors.success).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSpentMore ? Icons.trending_up : Icons.trending_down,
                      color: isSpentMore ? AppColors.danger : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comparison vs Previous Month',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSpentMore
                              ? 'Spent ${CurrencyFormatter.formatMinor(comp.differenceMinor.abs(), symbol: currencySymbol)} (+${comp.percentageChange.toStringAsFixed(1)}%) more than last month'
                              : 'Spent ${CurrencyFormatter.formatMinor(comp.differenceMinor.abs(), symbol: currencySymbol)} (-${comp.percentageChange.abs().toStringAsFixed(1)}%) less than last month',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Spending Trend Bar Chart
            Text(
              'Daily Spending Trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SpendWiseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Expenditure (Amount in ₹)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calcMaxY(report.dailyTrends),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Day ${group.x.toInt()}\n${CurrencyFormatter.formatDouble(rod.toY, symbol: currencySymbol)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (val, meta) {
                                final int day = val.toInt();
                                if (day == 1 || day == 10 || day == 20 || day == report.dailyTrends.length) {
                                  return Text(
                                    '$day',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: report.dailyTrends.map((trend) {
                          return BarChartGroupData(
                            x: trend.day,
                            barRods: [
                              BarChartRodData(
                                toY: CurrencyFormatter.minorToDouble(trend.amountMinor),
                                color: trend.amountMinor > 0 ? AppColors.primary : Colors.transparent,
                                width: 5,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category breakdown list
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
                    padding: const EdgeInsets.only(bottom: 12),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                catSpend.category.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                '${catSpend.count} transactions',
                                style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${catSpend.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(width: 12),
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
            const SizedBox(height: 30),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return SpendWiseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withAlpha(160))),
        ],
      ),
    );
  }

  double _calcMaxY(List<DaySpendTrend> trends) {
    double max = 1000;
    for (final t in trends) {
      final val = CurrencyFormatter.minorToDouble(t.amountMinor);
      if (val > max) max = val;
    }
    return max * 1.2;
  }
}
