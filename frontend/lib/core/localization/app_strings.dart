import 'package:flutter/material.dart';
import 'app_language.dart';
import 'locale_notifier.dart';
import 'strings_bn.dart';
import 'strings_en.dart';

/// বহুভাষিক টেক্সট রিট্রিভাল হেল্পার।
class AppStrings {
  static String tr(String key) {
    final lang = LocaleNotifier.instance.current;
    final dict = lang == AppLanguage.en ? stringsEn : stringsBn;
    return dict[key] ?? stringsBn[key] ?? key;
  }
}

extension AppStringsExtension on BuildContext {
  String tr(String key) => AppStrings.tr(key);
  bool get isBangla => LocaleNotifier.instance.isBangla;
  bool get isEnglish => LocaleNotifier.instance.isEnglish;
}
