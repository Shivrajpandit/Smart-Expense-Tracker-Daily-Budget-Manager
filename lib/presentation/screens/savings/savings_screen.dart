import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/savings_goal_model.dart';
import '../../providers/database_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/spendwise_card.dart';
import 'add_savings_goal_dialog.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings Goals',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Goal',
            onPressed: () => AddSavingsGoalDialog.show(context),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyStateView(
              icon: Icons.savings_outlined,
              title: 'No Savings Goals Yet',
              description: 'Set a goal to save for a vacation, gadget, emergency fund, or investment.',
              buttonText: 'Create Your First Goal',
              onButtonPressed: () => AddSavingsGoalDialog.show(context),
            );
          }

          int totalSavedMinor = 0;
          int totalTargetMinor = 0;
          for (final g in goals) {
            totalSavedMinor += g.currentAmountMinor;
            totalTargetMinor += g.targetAmountMinor;
          }

          final overallProgress = totalTargetMinor > 0
              ? (totalSavedMinor / totalTargetMinor).clamp(0.0, 1.0)
              : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overall Savings Card
              SpendWiseCard(
                gradient: const LinearGradient(
                  colors: AppColors.successGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Accumulated Savings',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatMinor(totalSavedMinor, symbol: currencySymbol),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(overallProgress * 100).toStringAsFixed(1)}% of total targets reached',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Target: ${CurrencyFormatter.formatMinor(totalTargetMinor, symbol: currencySymbol)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Active Goals (${goals.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              ...goals.map((goal) {
                final isReached = goal.currentAmountMinor >= goal.targetAmountMinor;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SpendWiseCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isReached ? AppColors.success : AppColors.primary).withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isReached ? Icons.check_circle : Icons.savings_outlined,
                                    color: isReached ? AppColors.success : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  goal.title,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'delete') {
                                  _deleteGoal(context, ref, goal);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                      SizedBox(width: 8),
                                      Text('Delete Goal', style: TextStyle(color: AppColors.danger)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.formatMinor(goal.currentAmountMinor, symbol: currencySymbol),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Target: ${CurrencyFormatter.formatMinor(goal.targetAmountMinor, symbol: currencySymbol)}',
                              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 8,
                            backgroundColor: theme.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isReached ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${goal.progressPercent.toStringAsFixed(1)}% achieved',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isReached ? AppColors.success : AppColors.primary,
                              ),
                            ),
                            if (goal.targetDate != null)
                              Text(
                                'Due by ${DateFormatter.formatDate(goal.targetDate!)}',
                                style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Funds to Goal'),
                            onPressed: () => _showAddFundsDialog(context, ref, goal),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal) {
    final controller = TextEditingController();
    final currencySymbol = ref.read(currencySymbolProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add to "${goal.title}"', style: const TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Deposit Amount ($currencySymbol)',
            hintText: 'e.g. 1000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final addedMinor = CurrencyFormatter.parseInputToMinor(controller.text);
              if (addedMinor <= 0) return;

              final updatedAmount = goal.currentAmountMinor + addedMinor;
              await ref.read(savingsRepositoryProvider).updateGoalProgress(goal.id, updatedAmount);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref, SavingsGoalModel goal) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Savings Goal',
      message: 'Are you sure you want to remove the goal "${goal.title}"?',
    );
    if (confirmed) {
      await ref.read(savingsRepositoryProvider).deleteGoal(goal.id);
    }
  }
}
