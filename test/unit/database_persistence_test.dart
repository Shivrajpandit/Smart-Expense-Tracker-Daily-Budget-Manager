import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/database/app_database.dart';
import 'package:spendwise/data/repositories/budget_repository.dart';
import 'package:spendwise/data/repositories/category_repository.dart';
import 'package:spendwise/data/repositories/expense_repository.dart';
import 'package:spendwise/data/repositories/income_repository.dart';
import 'package:spendwise/data/repositories/savings_repository.dart';
import 'package:spendwise/domain/models/category_model.dart';
import 'package:spendwise/domain/models/expense_model.dart';
import 'package:spendwise/domain/models/income_model.dart';
import 'package:spendwise/domain/models/savings_goal_model.dart';
import 'package:spendwise/domain/services/budget_calculator.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository expenseRepo;
  late CategoryRepository categoryRepo;
  late BudgetRepository budgetRepo;
  late IncomeRepository incomeRepo;
  late SavingsRepository savingsRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    expenseRepo = ExpenseRepository(db);
    categoryRepo = CategoryRepository(db);
    budgetRepo = BudgetRepository(db);
    incomeRepo = IncomeRepository(db);
    savingsRepo = SavingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database & Repositories Persistence', () {
    test('inserts and retrieves expenses persistently', () async {
      final now = DateTime(2026, 10, 27, 14, 30);
      final expense = ExpenseModel(
        id: 'exp_1',
        amountMinor: 45000, // ₹450.00
        categoryId: 'cat_food',
        description: 'Lunch Bowl',
        merchant: 'Salad Co',
        date: now,
        timeString: '02:30 PM',
        paymentMethod: 'UPI',
        notes: 'Healthy meal',
        createdAt: now,
        updatedAt: now,
      );

      await expenseRepo.insertExpense(expense);

      final retrieved = await expenseRepo.getExpenseById('exp_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.description, 'Lunch Bowl');
      expect(retrieved.amountMinor, 45000);
      expect(retrieved.amountDouble, 450.0);
      expect(retrieved.merchant, 'Salad Co');

      // Update expense
      final updated = retrieved.copyWith(amountMinor: 50000, description: 'Lunch Bowl + Juice');
      await expenseRepo.updateExpense(updated);

      final afterUpdate = await expenseRepo.getExpenseById('exp_1');
      expect(afterUpdate!.amountMinor, 50000);
      expect(afterUpdate.description, 'Lunch Bowl + Juice');

      // Delete expense
      await expenseRepo.deleteExpense('exp_1');
      final afterDelete = await expenseRepo.getExpenseById('exp_1');
      expect(afterDelete, isNull);
    });

    test('configures and persists monthly budget without modifying expenses', () async {
      await budgetRepo.setMonthlyBudget(
        year: 2026,
        month: 10,
        monthlyBudgetMinor: 5000000, // ₹50,000
        rolloverEnabled: true,
      );

      final settings = await budgetRepo.getBudgetForMonth(2026, 10);
      expect(settings.monthlyBudgetMinor, 5000000);
      expect(settings.monthlyBudgetDouble, 50000.0);
      expect(settings.rolloverEnabled, isTrue);

      // Verify planned daily calculation on persisted budget
      final days = BudgetCalculator.getDaysInMonth(2026, 10);
      final plannedDaily = BudgetCalculator.calculatePlannedDailyBudget(
        monthlyBudgetMinor: settings.monthlyBudgetMinor,
        daysInMonth: days,
      );
      expect(plannedDaily, (5000000 / 31).round());
    });

    test('supports custom categories insertion, query, and deletion', () async {
      final customCat = const CategoryModel(
        id: 'cat_custom_coffee',
        name: 'Artisan Coffee',
        iconCodePoint: 0xe532,
        colorValue: 0xFF8B5CF6,
        isDefault: false,
        isExpense: true,
      );

      await categoryRepo.insertCategory(customCat);

      final retrieved = await categoryRepo.getCategoryById('cat_custom_coffee');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Artisan Coffee');

      final deleted = await categoryRepo.deleteCategory('cat_custom_coffee');
      expect(deleted, isTrue);

      final afterDelete = await categoryRepo.getCategoryById('cat_custom_coffee');
      expect(afterDelete, isNull);
    });

    test('supports income entries and savings goals progress tracking', () async {
      final now = DateTime(2026, 10, 27);
      final income = IncomeModel(
        id: 'inc_1',
        amountMinor: 8000000, // ₹80,000
        source: 'Monthly Salary',
        categoryId: 'cat_salary',
        date: now,
        paymentMethod: 'Net Banking',
        createdAt: now,
      );

      await incomeRepo.insertIncome(income);
      final yearIncomes = await incomeRepo.getIncomesForYear(2026);
      expect(yearIncomes.length, 1);
      expect(yearIncomes.first.amountMinor, 8000000);

      // Savings Goal
      final goal = SavingsGoalModel(
        id: 'goal_laptop',
        title: 'New Workstation',
        targetAmountMinor: 10000000, // ₹100,000
        currentAmountMinor: 2500000, // ₹25,000
        createdAt: now,
      );

      await savingsRepo.insertGoal(goal);
      expect(goal.progress, 0.25);
      expect(goal.progressPercent, 25.0);

      // Deposit funds
      await savingsRepo.updateGoalProgress('goal_laptop', 5000000);
      final allGoals = await savingsRepo.watchSavingsGoals().first;
      expect(allGoals.first.currentAmountMinor, 5000000);
      expect(allGoals.first.progress, 0.50);
    });
  });
}
