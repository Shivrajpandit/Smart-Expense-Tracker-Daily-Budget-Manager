import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/models/savings_goal_model.dart';

class SavingsRepository {
  final AppDatabase _db;

  SavingsRepository(this._db);

  Stream<List<SavingsGoalModel>> watchSavingsGoals() {
    final query = _db.select(_db.savingsGoalsTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Future<void> insertGoal(SavingsGoalModel model) async {
    await _db.into(_db.savingsGoalsTable).insert(
          SavingsGoalsTableCompanion.insert(
            id: model.id,
            title: model.title,
            targetAmountMinor: model.targetAmountMinor,
            currentAmountMinor: Value(model.currentAmountMinor),
            targetDate: Value(model.targetDate),
            note: Value(model.note),
            colorValue: Value(model.colorValue),
            createdAt: model.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> updateGoalProgress(String id, int newCurrentAmountMinor) async {
    await (_db.update(_db.savingsGoalsTable)..where((tbl) => tbl.id.equals(id))).write(
      SavingsGoalsTableCompanion(
        currentAmountMinor: Value(newCurrentAmountMinor),
      ),
    );
  }

  Future<void> deleteGoal(String id) async {
    await (_db.delete(_db.savingsGoalsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  SavingsGoalModel _mapEntityToModel(SavingsGoalEntity entity) {
    return SavingsGoalModel(
      id: entity.id,
      title: entity.title,
      targetAmountMinor: entity.targetAmountMinor,
      currentAmountMinor: entity.currentAmountMinor,
      targetDate: entity.targetDate,
      note: entity.note,
      colorValue: entity.colorValue,
      createdAt: entity.createdAt,
    );
  }
}
