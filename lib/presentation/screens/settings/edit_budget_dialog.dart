import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/budget_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';

class EditBudgetDialog extends ConsumerStatefulWidget {
  const EditBudgetDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const EditBudgetDialog(),
    );
  }

  @override
  ConsumerState<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends ConsumerState<EditBudgetDialog> {
  late TextEditingController _budgetController;
  late bool _rolloverEnabled;

  @override
  void initState() {
    super.initState();
    final budgetSettings = ref.read(currentBudgetSettingsProvider).value;
    final currentBudget = budgetSettings?.monthlyBudgetMinor ?? 3000000;
    _rolloverEnabled = budgetSettings?.rolloverEnabled ?? false;
    _budgetController = TextEditingController(
      text: (currentBudget / 100.0).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    final monthYear = ref.watch(selectedMonthYearProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configure Monthly Budget', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            'For ${DateFormatter.formatMonthYear(DateTime(monthYear.year, monthYear.month, 1))}',
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Monthly Budget Limit',
                prefixText: '$currencySymbol ',
                prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                hintText: '30000',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Daily Budget Rollover',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text(
                'When enabled, unused daily budget carries forward to subsequent days of the month.',
                style: TextStyle(fontSize: 12),
              ),
              value: _rolloverEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _rolloverEnabled = val),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Changes to budget settings will not alter or delete any existing historical transaction records.',
                      style: TextStyle(fontSize: 11, color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text('Save Budget'),
        ),
      ],
    );
  }

  Future<void> _saveBudget() async {
    final minor = CurrencyFormatter.parseInputToMinor(_budgetController.text);
    if (minor <= 0) return;

    final monthYear = ref.read(selectedMonthYearProvider);
    await ref.read(budgetRepositoryProvider).setMonthlyBudget(
          year: monthYear.year,
          month: monthYear.month,
          monthlyBudgetMinor: minor,
          rolloverEnabled: _rolloverEnabled,
        );

    if (mounted) Navigator.of(context).pop();
  }
}
