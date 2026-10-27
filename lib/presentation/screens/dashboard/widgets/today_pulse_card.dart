import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/spendwise_card.dart';
import '../../../widgets/status_badge.dart';

class TodayPulseCard extends ConsumerWidget {
  const TodayPulseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calc = ref.watch(budgetCalculationProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    final isOverspent = calc.isDailyOverspent;
    final remaining = calc.remainingDailyAllowanceMinor;

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (isOverspent) {
      statusColor = AppColors.danger;
      statusLabel = 'Over Budget';
      statusIcon = Icons.warning_rounded;
    } else if (calc.dailyUtilizationPercent >= 80) {
      statusColor = AppColors.warning;
      statusLabel = 'Near Limit';
      statusIcon = Icons.timelapse_rounded;
    } else {
      statusColor = AppColors.success;
      statusLabel = 'On Track';
      statusIcon = Icons.check_circle_rounded;
    }

    final double progress = (calc.dailyUtilizationPercent / 100.0).clamp(0.0, 1.0);

    return SpendWiseCard(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryDark,
          const Color(0xFF3730A3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 310;
              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.today_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Today's Allowance",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormatter.getRelativeDateString(selectedDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      icon: statusIcon,
                      isFilled: true,
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.today_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Today's Allowance",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormatter.getRelativeDateString(selectedDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: StatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      icon: statusIcon,
                      isFilled: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Remaining daily allowance highlight
          Text(
            isOverspent ? 'Overspent by' : 'Remaining to Spend Today',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.formatMinor(
                  remaining.abs(),
                  symbol: currencySymbol,
                ),
                style: TextStyle(
                  color: isOverspent ? const Color(0xFFFCA5A5) : Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              if (calc.rolloverAmountMinor > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(50),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.secondary.withAlpha(100)),
                  ),
                  child: Text(
                    '+${CurrencyFormatter.formatMinor(calc.rolloverAmountMinor, symbol: currencySymbol)} rollover',
                    style: const TextStyle(
                      color: Color(0xFF67E8F9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverspent
                    ? AppColors.danger
                    : (progress > 0.8 ? AppColors.warning : AppColors.success),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick breakdown row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Spent Today',
                  value: CurrencyFormatter.formatMinor(
                    calc.totalSpentTodayMinor,
                    symbol: currencySymbol,
                  ),
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFFFCA5A5),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white.withAlpha(30)),
              Expanded(
                child: _buildMetricTile(
                  label: 'Today\'s Budget',
                  value: CurrencyFormatter.formatMinor(
                    calc.recommendedAvailableTodayMinor,
                    symbol: currencySymbol,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF93C5FD),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
