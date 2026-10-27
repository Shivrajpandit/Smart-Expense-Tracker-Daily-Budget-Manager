import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/models/income_model.dart';

class IncomeRepository {
  final AppDatabase _db;

  IncomeRepository(this._db);

  Stream<List<IncomeModel>> watchAllIncomes() {
    final query = _db.select(_db.incomesTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Stream<List<IncomeModel>> watchIncomesForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);

    final query = _db.select(_db.incomesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerOrEqualValue(end))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Future<List<IncomeModel>> getIncomesForYear(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59, 999);

    final query = _db.select(_db.incomesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerOrEqualValue(end))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    final entities = await query.get();
    return entities.map(_mapEntityToModel).toList();
  }

  Future<void> insertIncome(IncomeModel model) async {
    await _db.into(_db.incomesTable).insert(
          IncomesTableCompanion.insert(
            id: model.id,
            amountMinor: model.amountMinor,
            source: model.source,
            categoryId: model.categoryId,
            date: model.date,
            paymentMethod: model.paymentMethod,
            notes: Value(model.notes),
            createdAt: model.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> deleteIncome(String id) async {
    await (_db.delete(_db.incomesTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  IncomeModel _mapEntityToModel(IncomeEntity entity) {
    return IncomeModel(
      id: entity.id,
      amountMinor: entity.amountMinor,
      source: entity.source,
      categoryId: entity.categoryId,
      date: entity.date,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
