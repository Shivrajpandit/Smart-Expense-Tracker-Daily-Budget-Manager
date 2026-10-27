import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/filter_options.dart';

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  Stream<List<ExpenseModel>> watchAllExpenses() {
    final query = _db.select(_db.expensesTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Stream<List<ExpenseModel>> watchExpensesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final nextDay = DateTime(date.year, date.month, date.day + 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextDay))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Stream<List<ExpenseModel>> watchExpensesForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final nextMonth = DateTime(year, month + 1, 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextMonth))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Stream<List<ExpenseModel>> watchRecentExpenses({int limit = 5}) {
    final query = _db.select(_db.expensesTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date), (tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Future<List<ExpenseModel>> getExpensesForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final nextDay = DateTime(date.year, date.month, date.day + 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextDay))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    final entities = await query.get();
    return entities.map(_mapEntityToModel).toList();
  }

  Future<List<ExpenseModel>> getExpensesForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final nextMonth = DateTime(year, month + 1, 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextMonth))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    final entities = await query.get();
    return entities.map(_mapEntityToModel).toList();
  }

  Stream<List<ExpenseModel>> watchExpensesForYear(int year) {
    final start = DateTime(year, 1, 1);
    final nextYear = DateTime(year + 1, 1, 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextYear))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Future<List<ExpenseModel>> getExpensesForYear(int year) async {
    final start = DateTime(year, 1, 1);
    final nextYear = DateTime(year + 1, 1, 1);

    final query = _db.select(_db.expensesTable)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start) & tbl.date.isSmallerThanValue(nextYear))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);
    final entities = await query.get();
    return entities.map(_mapEntityToModel).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final entity = await (_db.select(_db.expensesTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return entity != null ? _mapEntityToModel(entity) : null;
  }

  Future<void> insertExpense(ExpenseModel model) async {
    await _db.into(_db.expensesTable).insert(
          ExpensesTableCompanion.insert(
            id: model.id,
            amountMinor: model.amountMinor,
            categoryId: model.categoryId,
            description: model.description,
            merchant: Value(model.merchant),
            date: model.date,
            timeString: model.timeString,
            paymentMethod: model.paymentMethod,
            notes: Value(model.notes),
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> updateExpense(ExpenseModel model) async {
    await (_db.update(_db.expensesTable)..where((tbl) => tbl.id.equals(model.id))).write(
      ExpensesTableCompanion(
        amountMinor: Value(model.amountMinor),
        categoryId: Value(model.categoryId),
        description: Value(model.description),
        merchant: Value(model.merchant),
        date: Value(model.date),
        timeString: Value(model.timeString),
        paymentMethod: Value(model.paymentMethod),
        notes: Value(model.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteExpense(String id) async {
    await (_db.delete(_db.expensesTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<List<ExpenseModel>> getFilteredExpenses(TransactionFilterOptions options) async {
    final query = _db.select(_db.expensesTable);

    if (options.startDate != null) {
      final start = DateTime(
        options.startDate!.year,
        options.startDate!.month,
        options.startDate!.day,
      );
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(start));
    }

    if (options.endDate != null) {
      final end = DateTime(
        options.endDate!.year,
        options.endDate!.month,
        options.endDate!.day,
        23,
        59,
        59,
        999,
      );
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(end));
    }

    if (options.categoryIds.isNotEmpty) {
      query.where((tbl) => tbl.categoryId.isIn(options.categoryIds));
    }

    if (options.paymentMethods.isNotEmpty) {
      query.where((tbl) => tbl.paymentMethod.isIn(options.paymentMethods));
    }

    // Sort order
    switch (options.sortOption) {
      case TransactionSortOption.dateDesc:
        query.orderBy([(tbl) => OrderingTerm.desc(tbl.date), (tbl) => OrderingTerm.desc(tbl.createdAt)]);
        break;
      case TransactionSortOption.dateAsc:
        query.orderBy([(tbl) => OrderingTerm.asc(tbl.date), (tbl) => OrderingTerm.asc(tbl.createdAt)]);
        break;
      case TransactionSortOption.amountDesc:
        query.orderBy([(tbl) => OrderingTerm.desc(tbl.amountMinor)]);
        break;
      case TransactionSortOption.amountAsc:
        query.orderBy([(tbl) => OrderingTerm.asc(tbl.amountMinor)]);
        break;
    }

    final entities = await query.get();
    var list = entities.map(_mapEntityToModel).toList();

    // In-memory text search on description, merchant, notes
    if (options.searchQuery.trim().isNotEmpty) {
      final q = options.searchQuery.trim().toLowerCase();
      list = list.where((item) {
        final descMatch = item.description.toLowerCase().contains(q);
        final merchMatch = item.merchant.toLowerCase().contains(q);
        final notesMatch = item.notes?.toLowerCase().contains(q) ?? false;
        return descMatch || merchMatch || notesMatch;
      }).toList();
    }

    return list;
  }

  ExpenseModel _mapEntityToModel(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      amountMinor: entity.amountMinor,
      categoryId: entity.categoryId,
      description: entity.description,
      merchant: entity.merchant,
      date: entity.date,
      timeString: entity.timeString,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
