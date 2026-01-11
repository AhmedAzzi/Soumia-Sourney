import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  late ThemeMode _themeMode;
  late Locale _locale;

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadSettings() {
    final isDark = StorageService.getIsDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final langCode = StorageService.getLanguageCode();
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    await StorageService.saveIsDarkMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await StorageService.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'ar') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }
}
