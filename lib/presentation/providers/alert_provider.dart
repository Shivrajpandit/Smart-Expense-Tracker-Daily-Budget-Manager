import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'budget_provider.dart';
import 'settings_provider.dart';

enum AlertSeverity {
  info,
  warning,
  danger,
}

class BudgetAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final IconData icon;

  const BudgetAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.icon,
  });

  Color get color {
    switch (severity) {
      case AlertSeverity.info:
        return AppColors.info;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.danger:
        return AppColors.danger;
    }
  }
}

final activeBudgetAlertsProvider = Provider<List<BudgetAlert>>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  if (!settings.alertsEnabled) return [];

  final calc = ref.watch(budgetCalculationProvider);
  final List<BudgetAlert> alerts = [];

  // Monthly alerts
  if (calc.isOverspent) {
    alerts.add(
      const BudgetAlert(
        id: 'monthly_overspent',
        title: 'Monthly Budget Exceeded',
        message: 'Your total monthly spending has surpassed your configured monthly budget.',
        severity: AlertSeverity.danger,
        icon: Icons.error_outline,
      ),
    );
  } else if (calc.utilizationPercent >= 80.0) {
    alerts.add(
      BudgetAlert(
        id: 'monthly_approaching',
        title: 'Monthly Budget Warning',
        message: 'You have used ${calc.utilizationPercent.toStringAsFixed(1)}% of your monthly budget.',
        severity: AlertSeverity.warning,
        icon: Icons.warning_amber_rounded,
      ),
    );
  }

  // Daily alerts
  if (calc.isDailyOverspent) {
    alerts.add(
      const BudgetAlert(
        id: 'daily_exceeded',
        title: 'Daily Budget Exceeded',
        message: 'You have spent more than your allocated daily allowance for today.',
        severity: AlertSeverity.danger,
        icon: Icons.trending_up,
      ),
    );
  } else if (calc.dailyUtilizationPercent >= 100.0) {
    alerts.add(
      const BudgetAlert(
        id: 'daily_reached',
        title: 'Daily Budget Reached',
        message: 'You have reached 100% of your daily spending limit today.',
        severity: AlertSeverity.warning,
        icon: Icons.timelapse,
      ),
    );
  } else if (calc.dailyUtilizationPercent >= 80.0) {
    alerts.add(
      BudgetAlert(
        id: 'daily_80',
        title: '80% of Daily Allowance Used',
        message: 'You have used ${calc.dailyUtilizationPercent.toStringAsFixed(1)}% of today\'s budget.',
        severity: AlertSeverity.warning,
        icon: Icons.notifications_active_outlined,
      ),
    );
  } else if (calc.dailyUtilizationPercent >= 50.0) {
    alerts.add(
      BudgetAlert(
        id: 'daily_50',
        title: '50% of Daily Allowance Used',
        message: 'Half of your recommended daily budget has been spent today.',
        severity: AlertSeverity.info,
        icon: Icons.info_outline,
      ),
    );
  }

  return alerts;
});
