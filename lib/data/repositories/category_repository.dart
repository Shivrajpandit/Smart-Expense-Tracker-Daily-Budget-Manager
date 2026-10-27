import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../domain/models/category_model.dart';

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository(this._db);

  Stream<List<CategoryModel>> watchCategories({bool? isExpense}) {
    final query = _db.select(_db.categoriesTable);
    if (isExpense != null) {
      query.where((tbl) => tbl.isExpense.equals(isExpense));
    }
    query.orderBy([(tbl) => OrderingTerm(expression: tbl.name)]);
    return query.watch().map((entities) => entities.map(_mapEntityToModel).toList());
  }

  Future<List<CategoryModel>> getCategories({bool? isExpense}) async {
    final query = _db.select(_db.categoriesTable);
    if (isExpense != null) {
      query.where((tbl) => tbl.isExpense.equals(isExpense));
    }
    query.orderBy([(tbl) => OrderingTerm(expression: tbl.name)]);
    final entities = await query.get();
    return entities.map(_mapEntityToModel).toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final entity = await (_db.select(_db.categoriesTable)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return entity != null ? _mapEntityToModel(entity) : null;
  }

  Future<void> insertCategory(CategoryModel model) async {
    await _db.into(_db.categoriesTable).insert(
          CategoriesTableCompanion.insert(
            id: model.id,
            name: model.name,
            iconCodePoint: model.iconCodePoint,
            iconFontFamily: Value(model.iconFontFamily),
            colorValue: model.colorValue,
            isDefault: Value(model.isDefault),
            isExpense: Value(model.isExpense),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> updateCategory(CategoryModel model) async {
    await (_db.update(_db.categoriesTable)..where((tbl) => tbl.id.equals(model.id))).write(
      CategoriesTableCompanion(
        name: Value(model.name),
        iconCodePoint: Value(model.iconCodePoint),
        iconFontFamily: Value(model.iconFontFamily),
        colorValue: Value(model.colorValue),
      ),
    );
  }

  Future<bool> deleteCategory(String id) async {
    // Check if category is default
    final cat = await getCategoryById(id);
    if (cat == null || cat.isDefault) return false;

    // Delete category
    await (_db.delete(_db.categoriesTable)..where((tbl) => tbl.id.equals(id))).go();
    return true;
  }

  CategoryModel _mapEntityToModel(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCodePoint: entity.iconCodePoint,
      iconFontFamily: entity.iconFontFamily,
      colorValue: entity.colorValue,
      isDefault: entity.isDefault,
      isExpense: entity.isExpense,
    );
  }
}
