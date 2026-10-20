/// অ্যাপের সমর্থিত ভাষাসমূহের তালিকা ও মেটাডাটা।
enum AppLanguage {
  bn('bn', 'বাংলা', '🇧🇩'),
  en('en', 'English', '🇬🇧');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String? code) {
    if (code == 'en') return AppLanguage.en;
    return AppLanguage.bn;
  }
}
