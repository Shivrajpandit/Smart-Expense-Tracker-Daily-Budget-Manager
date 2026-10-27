import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/alert_provider.dart';

class BudgetAlertBanner extends ConsumerWidget {
  const BudgetAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(activeBudgetAlertsProvider);
    if (alerts.isEmpty) return const SizedBox.shrink();

    // Show the highest severity alert
    final topAlert = alerts.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: topAlert.color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: topAlert.color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: topAlert.color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              topAlert.icon,
              size: 18,
              color: topAlert.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topAlert.title,
                  style: TextStyle(
                    color: topAlert.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topAlert.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
