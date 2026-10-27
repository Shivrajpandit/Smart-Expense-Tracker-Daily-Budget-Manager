import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/default_categories.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ExpensesTable,
  IncomesTable,
  CategoriesTable,
  BudgetSettingsTable,
  SavingsGoalsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'spendwise_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Seed default expense categories
          for (final cat in DefaultCategories.expenseCategories) {
            await into(categoriesTable).insert(
              CategoriesTableCompanion.insert(
                id: cat.id,
                name: cat.name,
                iconCodePoint: cat.iconCodePoint,
                iconFontFamily: Value(cat.iconFontFamily),
                colorValue: cat.colorValue,
                isDefault: const Value(true),
                isExpense: const Value(true),
              ),
            );
          }

          // Seed default income categories
          for (final cat in DefaultCategories.incomeCategories) {
            await into(categoriesTable).insert(
              CategoriesTableCompanion.insert(
                id: cat.id,
                name: cat.name,
                iconCodePoint: cat.iconCodePoint,
                iconFontFamily: Value(cat.iconFontFamily),
                colorValue: cat.colorValue,
                isDefault: const Value(true),
                isExpense: const Value(false),
              ),
            );
          }

          // Seed default budget for current month and year
          final now = DateTime.now();
          await into(budgetSettingsTable).insert(
            BudgetSettingsTableCompanion.insert(
              monthlyBudgetMinor: AppConstants.defaultMonthlyBudgetMinor,
              month: now.month,
              year: now.year,
              rolloverEnabled: const Value(false),
              createdAt: now,
            ),
          );
        },
      );
}
