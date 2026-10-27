import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class CurrencyOption {
  final String symbol;
  final String code;
  final String name;

  const CurrencyOption({
    required this.symbol,
    required this.code,
    required this.name,
  });
}

const List<CurrencyOption> supportedCurrencies = [
  CurrencyOption(symbol: '₹', code: 'INR', name: 'Indian Rupee (₹)'),
  CurrencyOption(symbol: '\$', code: 'USD', name: 'US Dollar (\$)'),
  CurrencyOption(symbol: '€', code: 'EUR', name: 'Euro (€)'),
  CurrencyOption(symbol: '£', code: 'GBP', name: 'British Pound (£)'),
  CurrencyOption(symbol: '¥', code: 'JPY', name: 'Japanese Yen (¥)'),
  CurrencyOption(symbol: 'C\$', code: 'CAD', name: 'Canadian Dollar (C\$)'),
  CurrencyOption(symbol: 'A\$', code: 'AUD', name: 'Australian Dollar (A\$)'),
  CurrencyOption(symbol: 'AED ', code: 'AED', name: 'UAE Dirham (AED)'),
  CurrencyOption(symbol: 'SGD ', code: 'SGD', name: 'Singapore Dollar (SGD)'),
];

class AppSettingsState {
  final ThemeMode themeMode;
  final String currencySymbol;
  final String currencyCode;
  final bool alertsEnabled;

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.currencySymbol = AppConstants.defaultCurrencySymbol,
    this.currencyCode = AppConstants.defaultCurrencyCode,
    this.alertsEnabled = true,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? currencySymbol,
    String? currencyCode,
    bool? alertsEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  static const _keyTheme = 'setting_theme';
  static const _keyCurrencySymbol = 'setting_currency_symbol';
  static const _keyCurrencyCode = 'setting_currency_code';
  static const _keyAlerts = 'setting_alerts_enabled';

  @override
  AppSettingsState build() {
    _loadSettings();
    return const AppSettingsState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_keyTheme);
      final symbol = prefs.getString(_keyCurrencySymbol) ?? AppConstants.defaultCurrencySymbol;
      final code = prefs.getString(_keyCurrencyCode) ?? AppConstants.defaultCurrencyCode;
      final alerts = prefs.getBool(_keyAlerts) ?? true;

      ThemeMode mode = ThemeMode.system;
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        mode = ThemeMode.values[themeIndex];
      }

      state = AppSettingsState(
        themeMode: mode,
        currencySymbol: symbol,
        currencyCode: code,
        alertsEnabled: alerts,
      );
    } catch (_) {
      // SharedPreferences fallback
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setCurrency(CurrencyOption option) async {
    state = state.copyWith(
      currencySymbol: option.symbol,
      currencyCode: option.code,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencySymbol, option.symbol);
    await prefs.setString(_keyCurrencyCode, option.code);
  }

  Future<void> setAlertsEnabled(bool enabled) async {
    state = state.copyWith(alertsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlerts, enabled);
  }
}

final settingsNotifierProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(AppSettingsNotifier.new);

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(settingsNotifierProvider).currencySymbol;
});
