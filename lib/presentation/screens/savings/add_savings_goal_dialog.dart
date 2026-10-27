import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/savings_goal_model.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';

class AddSavingsGoalDialog extends ConsumerStatefulWidget {
  const AddSavingsGoalDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const AddSavingsGoalDialog(),
    );
  }

  @override
  ConsumerState<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends ConsumerState<AddSavingsGoalDialog> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialSavedController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _initialSavedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('New Savings Goal', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title *',
                hintText: 'e.g. Vacation Fund, Emergency Fund',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target Amount ($currencySymbol) *',
                hintText: 'e.g. 50000',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _initialSavedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Already Saved ($currencySymbol)',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withAlpha(80)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _targetDate != null
                          ? 'Target Date: ${DateFormatter.formatDate(_targetDate!)}'
                          : 'Set Target Date (Optional)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add remarks...',
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
          onPressed: _saveGoal,
          child: const Text('Create Goal'),
        ),
      ],
    );
  }

  Future<void> _saveGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final targetMinor = CurrencyFormatter.parseInputToMinor(_targetAmountController.text);
    if (targetMinor <= 0) return;

    final initialMinor = CurrencyFormatter.parseInputToMinor(_initialSavedController.text);

    final goal = SavingsGoalModel(
      id: const Uuid().v4(),
      title: title,
      targetAmountMinor: targetMinor,
      currentAmountMinor: initialMinor,
      targetDate: _targetDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      colorValue: AppColors.success.toARGB32(),
      createdAt: DateTime.now(),
    );

    await ref.read(savingsRepositoryProvider).insertGoal(goal);
    if (mounted) Navigator.of(context).pop();
  }
}
