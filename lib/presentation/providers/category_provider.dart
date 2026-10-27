import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/category_model.dart';
import 'database_provider.dart';

final allCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});

final expenseCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories(isExpense: true);
});

final incomeCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories(isExpense: false);
});

final categoryMapProvider = Provider<Map<String, CategoryModel>>((ref) {
  final categoriesAsync = ref.watch(allCategoriesStreamProvider);
  return categoriesAsync.maybeWhen(
    data: (list) => {for (final item in list) item.id: item},
    orElse: () => {},
  );
});
