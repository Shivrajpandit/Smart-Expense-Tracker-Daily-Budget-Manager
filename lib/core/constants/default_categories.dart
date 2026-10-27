import 'package:flutter/material.dart';

class PredefinedCategoryData {
  final String id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int colorValue;
  final bool isExpense;

  const PredefinedCategoryData({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.colorValue,
    this.isExpense = true,
  });
}

class DefaultCategories {
  static const List<PredefinedCategoryData> expenseCategories = [
    PredefinedCategoryData(
      id: 'cat_food',
      name: 'Food & Dining',
      iconCodePoint: 0xe532, // restaurant
      colorValue: 0xFFFF7043, // Deep Orange
    ),
    PredefinedCategoryData(
      id: 'cat_groceries',
      name: 'Groceries',
      iconCodePoint: 0xe59c, // shopping_cart
      colorValue: 0xFF4CAF50, // Green
    ),
    PredefinedCategoryData(
      id: 'cat_transport',
      name: 'Transport',
      iconCodePoint: 0xe1d7, // directions_car
      colorValue: 0xFF29B6F6, // Light Blue
    ),
    PredefinedCategoryData(
      id: 'cat_shopping',
      name: 'Shopping',
      iconCodePoint: 0xe59b, // shopping_bag
      colorValue: 0xFFAB47BC, // Purple
    ),
    PredefinedCategoryData(
      id: 'cat_education',
      name: 'Education',
      iconCodePoint: 0xe559, // school
      colorValue: 0xFF26A69A, // Teal
    ),
    PredefinedCategoryData(
      id: 'cat_healthcare',
      name: 'Healthcare',
      iconCodePoint: 0xe3ae, // local_hospital
      colorValue: 0xFFEF5350, // Red
    ),
    PredefinedCategoryData(
      id: 'cat_entertainment',
      name: 'Entertainment',
      iconCodePoint: 0xe406, // movie
      colorValue: 0xFFFFA726, // Orange
    ),
    PredefinedCategoryData(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      iconCodePoint: 0xf2bb, // receipt_long
      colorValue: 0xFF5C6BC0, // Indigo
    ),
    PredefinedCategoryData(
      id: 'cat_subscriptions',
      name: 'Subscriptions',
      iconCodePoint: 0xe627, // subscriptions
      colorValue: 0xFFEC407A, // Pink
    ),
    PredefinedCategoryData(
      id: 'cat_other',
      name: 'Other Expenses',
      iconCodePoint: 0xe148, // category
      colorValue: 0xFF78909C, // Blue Grey
    ),
  ];

  static const List<PredefinedCategoryData> incomeCategories = [
    PredefinedCategoryData(
      id: 'cat_salary',
      name: 'Salary',
      iconCodePoint: 0xe040, // account_balance_wallet
      colorValue: 0xFF10B981, // Emerald
      isExpense: false,
    ),
    PredefinedCategoryData(
      id: 'cat_freelance',
      name: 'Freelance & Business',
      iconCodePoint: 0xe3be, // laptop
      colorValue: 0xFF06B6D4, // Cyan
      isExpense: false,
    ),
    PredefinedCategoryData(
      id: 'cat_investment',
      name: 'Investments & Returns',
      iconCodePoint: 0xe667, // trending_up
      colorValue: 0xFF8B5CF6, // Purple
      isExpense: false,
    ),
    PredefinedCategoryData(
      id: 'cat_other_income',
      name: 'Other Income',
      iconCodePoint: 0xe8e5, // monetization_on
      colorValue: 0xFFF59E0B, // Amber
      isExpense: false,
    ),
  ];

  // Available icon choices for custom categories
  static const List<IconData> availableCustomIcons = [
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.school,
    Icons.local_hospital,
    Icons.movie,
    Icons.receipt_long,
    Icons.subscriptions,
    Icons.category,
    Icons.fitness_center,
    Icons.flight,
    Icons.pets,
    Icons.home,
    Icons.card_giftcard,
    Icons.coffee,
    Icons.sports_esports,
    Icons.child_care,
    Icons.brush,
    Icons.phone_android,
  ];

  // Available color palette for custom categories
  static const List<Color> availableCustomColors = [
    Color(0xFFFF7043),
    Color(0xFF4CAF50),
    Color(0xFF29B6F6),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFF5C6BC0),
    Color(0xFFEC407A),
    Color(0xFF78909C),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF43F5E),
    Color(0xFFEAB308),
  ];
}
