import 'package:drift/drift.dart';

@DataClassName('ExpenseEntity')
class ExpensesTable extends Table {
  TextColumn get id => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get categoryId => text()();
  TextColumn get description => text()();
  TextColumn get merchant => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get timeString => text()();
  TextColumn get paymentMethod => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('IncomeEntity')
class IncomesTable extends Table {
  TextColumn get id => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get source => text()();
  TextColumn get categoryId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryEntity')
class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily => text().withDefault(const Constant('MaterialIcons'))();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetSettingEntity')
class BudgetSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get monthlyBudgetMinor => integer()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  BoolColumn get rolloverEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('SavingsGoalEntity')
class SavingsGoalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get targetAmountMinor => integer()();
  IntColumn get currentAmountMinor => integer().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF10B981))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
