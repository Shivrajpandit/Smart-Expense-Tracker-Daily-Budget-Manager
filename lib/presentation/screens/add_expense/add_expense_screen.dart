import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/default_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/category_model.dart';
import '../../../domain/models/expense_model.dart';
import '../../../domain/models/income_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expenseToEdit;
  final DateTime? initialDate;

  const AddExpenseScreen({super.key, this.expenseToEdit, this.initialDate});

  static Future<void> show(BuildContext context, {ExpenseModel? expenseToEdit, DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddExpenseScreen(
        expenseToEdit: expenseToEdit,
        initialDate: initialDate,
      ),
    );
  }

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isExpense = true;
  String? _selectedCategoryId;
  String _selectedPaymentMethod = 'UPI';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _amountController.text = (e.amountMinor / 100.0).toStringAsFixed(2);
      _descController.text = e.description;
      _merchantController.text = e.merchant;
      _notesController.text = e.notes ?? '';
      _selectedCategoryId = e.categoryId;
      _selectedPaymentMethod = e.paymentMethod;
      _selectedDate = e.date;
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addQuickAmount(int amount) {
    final current = double.tryParse(_amountController.text) ?? 0;
    final updated = current + amount;
    _amountController.text = updated % 1 == 0 ? updated.toInt().toString() : updated.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final isEditing = widget.expenseToEdit != null;

    final categoriesAsync = _isExpense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing
                      ? 'Edit Expense'
                      : (_isExpense ? 'Add Expense' : 'Add Income'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expense vs Income toggle (only when creating new)
                    if (!isEditing) ...[
                      Center(
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Expense'),
                              icon: Icon(Icons.arrow_upward, size: 16),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Income'),
                              icon: Icon(Icons.arrow_downward, size: 16),
                            ),
                          ],
                          selected: {_isExpense},
                          onSelectionChanged: (set) {
                            setState(() {
                              _isExpense = set.first;
                              _selectedCategoryId = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Amount Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: _isExpense ? AppColors.danger : AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter an amount';
                                    }
                                    final d = double.tryParse(val.replaceAll(',', '').trim());
                                    if (d == null || d <= 0) {
                                      return 'Amount must be greater than zero';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick denomination chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickAmountChip(50),
                          _buildQuickAmountChip(100),
                          _buildQuickAmountChip(200),
                          _buildQuickAmountChip(500),
                          _buildQuickAmountChip(1000),
                          _buildQuickAmountChip(2000),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Custom'),
                          onPressed: () => _showAddCustomCategoryDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Text('No categories available');
                        }
                        if (_selectedCategoryId == null && categories.isNotEmpty) {
                          _selectedCategoryId = categories.first.id;
                        }

                        return SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = _selectedCategoryId == cat.id;
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() => _selectedCategoryId = cat.id),
                                child: Container(
                                  width: 76,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cat.color.withAlpha(40)
                                        : theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? cat.color : theme.dividerColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: cat.color.withAlpha(30),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(cat.iconData, color: cat.color, size: 20),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? cat.color : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error loading categories: $err'),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Description *',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Lunch with team, Groceries',
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Merchant / Location
                    Text(
                      'Merchant / Location (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _merchantController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Starbucks, Amazon, Shell',
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date & Time row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormatter.formatDate(_selectedDate),
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormatter.formatTimeOfDay(_selectedTime),
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment Method selector
                    Text(
                      'Payment Method',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.paymentMethods.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        return ChoiceChip(
                          label: Text(method),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedPaymentMethod = method);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Optional Notes
                    Text(
                      'Notes (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Add additional context or memo...',
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isExpense ? AppColors.primary : AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveRecord,
                        child: Text(
                          isEditing ? 'Update Expense' : (_isExpense ? 'Save Expense' : 'Save Income'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(int amount) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text('+$currencySymbol$amount'),
        onPressed: () => _addQuickAmount(amount),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amountMinor = CurrencyFormatter.parseInputToMinor(_amountController.text);
    if (amountMinor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be positive')),
      );
      return;
    }

    final now = DateTime.now();
    final timeStr = DateFormatter.formatTimeOfDay(_selectedTime);

    final recordDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (_isExpense) {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      if (widget.expenseToEdit != null) {
        final updated = widget.expenseToEdit!.copyWith(
          amountMinor: amountMinor,
          categoryId: _selectedCategoryId!,
          description: _descController.text.trim(),
          merchant: _merchantController.text.trim(),
          date: recordDate,
          timeString: timeStr,
          paymentMethod: _selectedPaymentMethod,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          updatedAt: now,
        );
        await expenseRepo.updateExpense(updated);
      } else {
        final expense = ExpenseModel(
          id: const Uuid().v4(),
          amountMinor: amountMinor,
          categoryId: _selectedCategoryId!,
          description: _descController.text.trim(),
          merchant: _merchantController.text.trim(),
          date: recordDate,
          timeString: timeStr,
          paymentMethod: _selectedPaymentMethod,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await expenseRepo.insertExpense(expense);
      }
    } else {
      final incomeRepo = ref.read(incomeRepositoryProvider);
      final income = IncomeModel(
        id: const Uuid().v4(),
        amountMinor: amountMinor,
        source: _descController.text.trim(),
        categoryId: _selectedCategoryId!,
        date: recordDate,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
      );
      await incomeRepo.insertIncome(income);
    }

    // Invalidate state so any UI consumers update immediately
    ref.invalidate(selectedDateExpensesProvider);
    ref.invalidate(currentMonthExpensesProvider);
    ref.invalidate(allExpensesStreamProvider);
    ref.invalidate(recentExpensesStreamProvider);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isExpense ? 'Expense saved successfully!' : 'Income saved successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddCustomCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = DefaultCategories.availableCustomColors.first;
    IconData selectedIcon = DefaultCategories.availableCustomIcons.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Custom Category', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Gym, Pet Care',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pick an Icon:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DefaultCategories.availableCustomIcons.map((icon) {
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
                const SizedBox(height: 16),
                const Text('Pick a Color:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DefaultCategories.availableCustomColors.map((color) {
                    final isColorSelected = selectedColor == color;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedColor = color),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
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
                  isExpense: _isExpense,
                );

                await ref.read(categoryRepositoryProvider).insertCategory(newCat);
                setState(() => _selectedCategoryId = newCat.id);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
