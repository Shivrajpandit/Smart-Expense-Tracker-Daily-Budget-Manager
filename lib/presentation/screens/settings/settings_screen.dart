import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/expense_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/spendwise_card.dart';
import 'edit_budget_dialog.dart';
import 'export_data_dialog.dart';
import 'manage_categories_screen.dart';
import '../savings/savings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final budgetSettings = ref.watch(currentBudgetSettingsProvider).value;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    final currentBudgetMinor = budgetSettings?.monthlyBudgetMinor ?? AppConstants.defaultMonthlyBudgetMinor;
    final isRollover = budgetSettings?.rolloverEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Budget & Preferences
          _sectionHeader('Budget & Calculations'),
          SpendWiseCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                  title: const Text('Monthly Budget Limit', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    CurrencyFormatter.formatMinor(currentBudgetMinor, symbol: currencySymbol),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => EditBudgetDialog.show(context),
                ),
                const Divider(indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.repeat_rounded, color: AppColors.secondary),
                  title: const Text('Daily Budget Rollover', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Carry forward unused daily allowance', style: TextStyle(fontSize: 12)),
                  value: isRollover,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    final monthYear = ref.read(selectedMonthYearProvider);
                    ref.read(budgetRepositoryProvider).toggleRollover(
                          year: monthYear.year,
                          month: monthYear.month,
                          enabled: val,
                        );
                  },
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.category_outlined, color: AppColors.warning),
                  title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Predefined & custom category list', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
                  ),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.savings_outlined, color: AppColors.success),
                  title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Monitor targets and deposit progress', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SavingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Preferences (Currency & Theme)
          _sectionHeader('Preferences & Localization'),
          SpendWiseCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.success),
                  title: const Text('Currency Symbol & Code', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${settings.currencySymbol} (${settings.currencyCode})', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCurrencyPicker(context, ref),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined, color: AppColors.info),
                  title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_getThemeName(settings.themeMode), style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePicker(context, ref, settings.themeMode),
                ),
                const Divider(indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.warning),
                  title: const Text('Budget Warnings & Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Show visual banners for 50%, 80%, and exceeded limits', style: TextStyle(fontSize: 12)),
                  value: settings.alertsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => ref.read(settingsNotifierProvider.notifier).setAlertsEnabled(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Data & Backup
          _sectionHeader('Data & Backup'),
          SpendWiseCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                  title: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Export transactions to CSV or text summary', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ExportDataDialog.show(context),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppColors.secondary),
                  title: const Text('Backup Data (JSON)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Create a JSON snapshot of all expenses', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportJsonBackup(context, ref),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.restore_outlined, color: AppColors.info),
                  title: const Text('Restore Data (JSON)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Import transactions from backup text', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestoreJsonDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Cloud Sync (Future extension)
          _sectionHeader('Cloud & Accounts'),
          SpendWiseCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_queue, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline-First Local Storage',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your data is securely stored on your device using SQLite. Firebase cloud sync is available as an optional extension.',
                        style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About app
          Center(
            child: Column(
              children: [
                Text(
                  'SpendWise v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withAlpha(150)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
    }
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: supportedCurrencies.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (ctx, i) {
          final opt = supportedCurrencies[i];
          return ListTile(
            leading: Text(opt.symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            title: Text(opt.name),
            subtitle: Text('Code: ${opt.code}'),
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).setCurrency(opt);
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.of(ctx).pop();
            },
            child: Row(
              children: [
                Icon(current == ThemeMode.system ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('System Default'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.of(ctx).pop();
            },
            child: Row(
              children: [
                Icon(current == ThemeMode.light ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Light Mode'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.of(ctx).pop();
            },
            child: Row(
              children: [
                Icon(current == ThemeMode.dark ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Dark Mode'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportJsonBackup(BuildContext context, WidgetRef ref) async {
    final allExpenses = await ref.read(expenseRepositoryProvider).watchAllExpenses().first;
    final jsonList = allExpenses.map((e) => e.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('JSON Backup Snapshot', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy JSON'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup JSON copied to clipboard!')),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  void _showRestoreJsonDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restore from JSON', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste a valid JSON backup array below to restore transactions.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '[{"id": "...", "amountMinor": 50000, ...}]',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final text = controller.text.trim();
                final List<dynamic> decoded = jsonDecode(text);
                final expenseRepo = ref.read(expenseRepositoryProvider);

                int restoredCount = 0;
                for (final item in decoded) {
                  if (item is Map<String, dynamic>) {
                    final exp = ExpenseModel.fromJson(item);
                    await expenseRepo.insertExpense(exp);
                    restoredCount++;
                  }
                }

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully restored $restoredCount transactions!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid JSON format: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
