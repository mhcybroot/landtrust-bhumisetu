import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

/// সমগ্র অ্যাপের ভাষা নিয়ন্ত্রণ ও পারসিস্টেন্স সার্ভিস।
class LocaleNotifier extends ChangeNotifier {
  static final LocaleNotifier instance = LocaleNotifier._internal();
  LocaleNotifier._internal();

  static const String _prefKey = 'selected_app_language';
  AppLanguage _current = AppLanguage.bn;

  AppLanguage get current => _current;
  bool get isBangla => _current == AppLanguage.bn;
  bool get isEnglish => _current == AppLanguage.en;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        _current = AppLanguage.fromCode(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final next = isBangla ? AppLanguage.en : AppLanguage.bn;
    await setLanguage(next);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_current == lang) return;
    _current = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang.code);
    } catch (_) {}
  }
}
