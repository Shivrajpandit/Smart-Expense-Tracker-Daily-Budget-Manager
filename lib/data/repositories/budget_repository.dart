import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/models/budget_settings_model.dart';
import '../../core/constants/app_constants.dart';

class BudgetRepository {
  final AppDatabase _db;

  BudgetRepository(this._db);

  Stream<BudgetSettingsModel> watchBudgetForMonth(int year, int month) {
    final query = _db.select(_db.budgetSettingsTable)
      ..where((tbl) => tbl.year.equals(year) & tbl.month.equals(month))
      ..limit(1);

    return query.watchSingleOrNull().map((entity) {
      if (entity != null) {
        return _mapEntityToModel(entity);
      }
      return BudgetSettingsModel(
        monthlyBudgetMinor: AppConstants.defaultMonthlyBudgetMinor,
        month: month,
        year: year,
        rolloverEnabled: false,
        createdAt: DateTime.now(),
      );
    });
  }

  Future<BudgetSettingsModel> getBudgetForMonth(int year, int month) async {
    final entity = await (_db.select(_db.budgetSettingsTable)
          ..where((tbl) => tbl.year.equals(year) & tbl.month.equals(month))
          ..limit(1))
        .getSingleOrNull();

    if (entity != null) {
      return _mapEntityToModel(entity);
    }

    // Try finding the latest existing budget to carry forward the user's preferred limit
    final latest = await (_db.select(_db.budgetSettingsTable)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
          ..limit(1))
        .getSingleOrNull();

    final budgetMinor = latest?.monthlyBudgetMinor ?? AppConstants.defaultMonthlyBudgetMinor;
    final rollover = latest?.rolloverEnabled ?? false;

    // Create a record for this month
    final companion = BudgetSettingsTableCompanion.insert(
      monthlyBudgetMinor: budgetMinor,
      month: month,
      year: year,
      rolloverEnabled: Value(rollover),
      createdAt: DateTime.now(),
    );
    final id = await _db.into(_db.budgetSettingsTable).insert(companion);

    return BudgetSettingsModel(
      id: id,
      monthlyBudgetMinor: budgetMinor,
      month: month,
      year: year,
      rolloverEnabled: rollover,
      createdAt: DateTime.now(),
    );
  }

  Future<void> setMonthlyBudget({
    required int year,
    required int month,
    required int monthlyBudgetMinor,
    bool? rolloverEnabled,
  }) async {
    final existing = await (_db.select(_db.budgetSettingsTable)
          ..where((tbl) => tbl.year.equals(year) & tbl.month.equals(month))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.budgetSettingsTable)..where((tbl) => tbl.id.equals(existing.id))).write(
        BudgetSettingsTableCompanion(
          monthlyBudgetMinor: Value(monthlyBudgetMinor),
          rolloverEnabled: rolloverEnabled != null ? Value(rolloverEnabled) : const Value.absent(),
        ),
      );
    } else {
      await _db.into(_db.budgetSettingsTable).insert(
            BudgetSettingsTableCompanion.insert(
              monthlyBudgetMinor: monthlyBudgetMinor,
              month: month,
              year: year,
              rolloverEnabled: Value(rolloverEnabled ?? false),
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> toggleRollover({
    required int year,
    required int month,
    required bool enabled,
  }) async {
    final existing = await getBudgetForMonth(year, month);
    await setMonthlyBudget(
      year: year,
      month: month,
      monthlyBudgetMinor: existing.monthlyBudgetMinor,
      rolloverEnabled: enabled,
    );
  }

  BudgetSettingsModel _mapEntityToModel(BudgetSettingEntity entity) {
    return BudgetSettingsModel(
      id: entity.id,
      monthlyBudgetMinor: entity.monthlyBudgetMinor,
      month: entity.month,
      year: entity.year,
      rolloverEnabled: entity.rolloverEnabled,
      createdAt: entity.createdAt,
    );
  }
}
