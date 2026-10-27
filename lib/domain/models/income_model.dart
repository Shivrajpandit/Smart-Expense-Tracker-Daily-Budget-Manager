class IncomeModel {
  final String id;
  final int amountMinor;
  final String source;
  final String categoryId;
  final DateTime date;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;

  const IncomeModel({
    required this.id,
    required this.amountMinor,
    required this.source,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  double get amountDouble => amountMinor / 100.0;

  IncomeModel copyWith({
    String? id,
    int? amountMinor,
    String? source,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      source: source ?? this.source,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMinor': amountMinor,
      'source': source,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as String,
      amountMinor: json['amountMinor'] as int,
      source: json['source'] as String,
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
