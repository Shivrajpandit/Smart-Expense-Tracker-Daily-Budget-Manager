import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/yearly_report.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/reports_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/spendwise_card.dart';

class YearlyReportView extends ConsumerWidget {
  const YearlyReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthYear = ref.watch(selectedMonthYearProvider);
    final reportAsync = ref.watch(yearlyReportProvider(monthYear.year));
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return reportAsync.when(
      data: (report) {
        if (report.totalExpensesMinor == 0 && report.totalIncomeMinor == 0) {
          return EmptyStateView(
            icon: Icons.calendar_today_outlined,
            title: 'No Data for ${report.year}',
            description: 'There are no transactions recorded for the year ${report.year}.',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Overview
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Yearly Expenses',
                    value: CurrencyFormatter.formatMinor(report.totalExpensesMinor, symbol: currencySymbol),
                    subtitle: 'Avg: ${CurrencyFormatter.formatMinor(report.averageMonthlyExpenditureMinor, symbol: currencySymbol)}/mo',
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Income',
                    value: CurrencyFormatter.formatMinor(report.totalIncomeMinor, symbol: currencySymbol),
                    subtitle: 'Net: ${CurrencyFormatter.formatMinor(report.netSavingsMinor, symbol: currencySymbol)}',
                    color: AppColors.success,
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
                    title: 'Peak Spending Month',
                    value: report.highestSpendingMonth != null
                        ? report.highestSpendingMonth!.monthName
                        : 'N/A',
                    subtitle: report.highestSpendingMonth != null
                        ? CurrencyFormatter.formatMinor(report.highestSpendingMonth!.totalExpenseMinor, symbol: currencySymbol)
                        : '',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Lowest Spending Month',
                    value: report.lowestSpendingMonth != null
                        ? report.lowestSpendingMonth!.monthName
                        : 'N/A',
                    subtitle: report.lowestSpendingMonth != null
                        ? CurrencyFormatter.formatMinor(report.lowestSpendingMonth!.totalExpenseMinor, symbol: currencySymbol)
                        : '',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 12-Month Expense Comparison Bar Chart
            Text(
              '12-Month Spending Comparison',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SpendWiseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Expense Volume (Amount in ₹)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 190,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calcMaxY(report.monthlySummaries),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final summary = report.monthlySummaries[group.x.toInt() - 1];
                              return BarTooltipItem(
                                '${summary.monthName}\n${CurrencyFormatter.formatDouble(rod.toY, symbol: currencySymbol)}',
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
                                final int index = val.toInt() - 1;
                                if (index >= 0 && index < report.monthlySummaries.length) {
                                  // Show every alternate month to avoid crowding
                                  if (index % 2 == 0) {
                                    return Text(
                                      report.monthlySummaries[index].monthName,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    );
                                  }
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: report.monthlySummaries.map((summary) {
                          return BarChartGroupData(
                            x: summary.month,
                            barRods: [
                              BarChartRodData(
                                toY: CurrencyFormatter.minorToDouble(summary.totalExpenseMinor),
                                color: summary.totalExpenseMinor > 0 ? AppColors.primary : Colors.transparent,
                                width: 12,
                                borderRadius: BorderRadius.circular(4),
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

            // Annual Category Breakdown
            Text(
              'Annual Category Breakdown',
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
                                '${catSpend.count} transactions in ${report.year}',
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

  double _calcMaxY(List<MonthSpendSummary> summaries) {
    double max = 1000;
    for (final s in summaries) {
      final val = CurrencyFormatter.minorToDouble(s.totalExpenseMinor);
      if (val > max) max = val;
    }
    return max * 1.2;
  }
}
