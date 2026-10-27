import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/default_categories.dart';
import '../../../domain/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/spendwise_card.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Category',
            onPressed: () => _showAddCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final defaultCats = categories.where((c) => c.isDefault).toList();
          final customCats = categories.where((c) => !c.isDefault).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (customCats.isNotEmpty) ...[
                const Text(
                  'Custom Categories',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SpendWiseCard(
                  padding: const EdgeInsets.all(4),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customCats.length,
                    separatorBuilder: (context, index) => const Divider(indent: 56),
                    itemBuilder: (context, index) {
                      final cat = customCats[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cat.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(cat.iconData, color: cat.color, size: 20),
                        ),
                        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(cat.isExpense ? 'Expense' : 'Income', style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () async {
                            final confirmed = await ConfirmationDialog.show(
                              context: context,
                              title: 'Delete Category',
                              message: 'Delete "${cat.name}" category?',
                            );
                            if (confirmed) {
                              await ref.read(categoryRepositoryProvider).deleteCategory(cat.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Predefined Categories',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SpendWiseCard(
                padding: const EdgeInsets.all(4),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultCats.length,
                  separatorBuilder: (context, index) => const Divider(indent: 56),
                  itemBuilder: (context, index) {
                    final cat = defaultCats[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cat.color.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.iconData, color: cat.color, size: 20),
                      ),
                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(cat.isExpense ? 'Default Expense' : 'Default Income', style: const TextStyle(fontSize: 11)),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    Color selectedColor = DefaultCategories.availableCustomColors.first;
    IconData selectedIcon = DefaultCategories.availableCustomIcons.first;
    bool isExpense = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Custom Category', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Expense')),
                    ButtonSegment(value: false, label: Text('Income')),
                  ],
                  selected: {isExpense},
                  onSelectionChanged: (set) => setDialogState(() => isExpense = set.first),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Subscriptions',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DefaultCategories.availableCustomIcons.take(12).map((icon) {
                    final isIconSelected = selectedIcon == icon;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = icon),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isIconSelected ? selectedColor.withAlpha(50) : null,
                          border: Border.all(
                            color: isIconSelected ? selectedColor : Colors.grey.withAlpha(50),
                            width: isIconSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 20, color: isIconSelected ? selectedColor : null),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Choose Color:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DefaultCategories.availableCustomColors.take(10).map((color) {
                    final isColorSelected = selectedColor == color;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedColor = color),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isColorSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final newCat = CategoryModel(
                  id: 'custom_${const Uuid().v4()}',
                  name: name,
                  iconCodePoint: selectedIcon.codePoint,
                  iconFontFamily: selectedIcon.fontFamily ?? 'MaterialIcons',
                  colorValue: selectedColor.toARGB32(),
                  isDefault: false,
                  isExpense: isExpense,
                );

                await ref.read(categoryRepositoryProvider).insertCategory(newCat);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}
