class SavingsGoalModel {
  final String id;
  final String title;
  final int targetAmountMinor;
  final int currentAmountMinor;
  final DateTime? targetDate;
  final String? note;
  final int colorValue;
  final DateTime createdAt;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmountMinor,
    this.currentAmountMinor = 0,
    this.targetDate,
    this.note,
    this.colorValue = 0xFF10B981, // Emerald
    required this.createdAt,
  });

  double get targetAmountDouble => targetAmountMinor / 100.0;
  double get currentAmountDouble => currentAmountMinor / 100.0;
  double get progress => targetAmountMinor > 0
      ? (currentAmountMinor / targetAmountMinor).clamp(0.0, 1.0)
      : 0.0;
  double get progressPercent => progress * 100;
  int get remainingMinor => (targetAmountMinor - currentAmountMinor).clamp(0, targetAmountMinor);

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    int? targetAmountMinor,
    int? currentAmountMinor,
    DateTime? targetDate,
    String? note,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
      currentAmountMinor: currentAmountMinor ?? this.currentAmountMinor,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmountMinor': targetAmountMinor,
      'currentAmountMinor': currentAmountMinor,
      'targetDate': targetDate?.toIso8601String(),
      'note': note,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmountMinor: json['targetAmountMinor'] as int,
      currentAmountMinor: json['currentAmountMinor'] as int? ?? 0,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      note: json['note'] as String?,
      colorValue: json['colorValue'] as int? ?? 0xFF10B981,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
