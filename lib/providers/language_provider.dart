import 'package:flutter/foundation.dart';
import '../localization/app_strings.dart';

enum AppLanguage { en, mk }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en;

  AppLanguage get language => _language;

  set language(AppLanguage value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }

  AppStrings get strings => AppStrings(_language);
}
