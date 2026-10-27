class ExpenseModel {
  final String id;
  final int amountMinor; // in minor units (paise/cents, integer)
  final String categoryId;
  final String description;
  final String merchant;
  final DateTime date;
  final String timeString; // e.g. "02:30 PM"
  final String paymentMethod; // e.g. "UPI", "Cash", etc.
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.amountMinor,
    required this.categoryId,
    required this.description,
    this.merchant = '',
    required this.date,
    required this.timeString,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get amountDouble => amountMinor / 100.0;

  ExpenseModel copyWith({
    String? id,
    int? amountMinor,
    String? categoryId,
    String? description,
    String? merchant,
    DateTime? date,
    String? timeString,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      timeString: timeString ?? this.timeString,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMinor': amountMinor,
      'categoryId': categoryId,
      'description': description,
      'merchant': merchant,
      'date': date.toIso8601String(),
      'timeString': timeString,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amountMinor: json['amountMinor'] as int,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      merchant: json['merchant'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      timeString: json['timeString'] as String,
      paymentMethod: json['paymentMethod'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
