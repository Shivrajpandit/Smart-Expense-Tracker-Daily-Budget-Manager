import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/savings_goal_model.dart';
import '../../domain/models/income_model.dart';
import 'database_provider.dart';

final savingsGoalsStreamProvider = StreamProvider<List<SavingsGoalModel>>((ref) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchSavingsGoals();
});

final allIncomesStreamProvider = StreamProvider<List<IncomeModel>>((ref) {
  final repo = ref.watch(incomeRepositoryProvider);
  return repo.watchAllIncomes();
});
