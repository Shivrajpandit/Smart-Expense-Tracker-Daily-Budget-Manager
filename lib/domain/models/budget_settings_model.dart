class BudgetSettingsModel {
  final int id;
  final int monthlyBudgetMinor; // e.g. 3000000 = ₹30,000
  final int month; // 1 - 12
  final int year; // e.g. 2026
  final bool rolloverEnabled; // carry forward unused daily budget
  final DateTime createdAt;

  const BudgetSettingsModel({
    this.id = 1,
    required this.monthlyBudgetMinor,
    required this.month,
    required this.year,
    this.rolloverEnabled = false,
    required this.createdAt,
  });

  double get monthlyBudgetDouble => monthlyBudgetMinor / 100.0;

  BudgetSettingsModel copyWith({
    int? id,
    int? monthlyBudgetMinor,
    int? month,
    int? year,
    bool? rolloverEnabled,
    DateTime? createdAt,
  }) {
    return BudgetSettingsModel(
      id: id ?? this.id,
      monthlyBudgetMinor: monthlyBudgetMinor ?? this.monthlyBudgetMinor,
      month: month ?? this.month,
      year: year ?? this.year,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthlyBudgetMinor': monthlyBudgetMinor,
      'month': month,
      'year': year,
      'rolloverEnabled': rolloverEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetSettingsModel.fromJson(Map<String, dynamic> json) {
    return BudgetSettingsModel(
      id: json['id'] as int? ?? 1,
      monthlyBudgetMinor: json['monthlyBudgetMinor'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      rolloverEnabled: json['rolloverEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
