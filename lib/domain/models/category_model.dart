import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;
  final bool isDefault;
  final bool isExpense;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.colorValue,
    this.isDefault = false,
    this.isExpense = true,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get iconData => IconData(iconCodePoint, fontFamily: iconFontFamily);
  Color get color => Color(colorValue);

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    bool? isDefault,
    bool? isExpense,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'isExpense': isExpense,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      isExpense: json['isExpense'] as bool? ?? true,
    );
  }
}
