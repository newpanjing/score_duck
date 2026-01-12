import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const _key = 'locale';
  static LanguageController get to => Get.find();

  final Rx<Locale?> _currentLocale = Rx<Locale?>(null);
  Locale? get currentLocale => _currentLocale.value;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Locale? _stringToLocale(String? localeString) {
    if (localeString == null || localeString == 'system') return null;
    if (localeString.contains('_')) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      } else if (parts.length == 3) {
        return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1], countryCode: parts[2]);
      }
    }
    return Locale(localeString);
  }

  String _localeToString(Locale? locale) {
    if (locale == null) return 'system';
    return locale.toString();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_key);
      final locale = _stringToLocale(lang);
      _currentLocale.value = locale;
    } catch (e) {
      _currentLocale.value = null;
    }
  }

  Future<void> setLanguage(Locale? locale) async {
    _currentLocale.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _localeToString(locale));
    
    // Update GetX locale for translations
    if (locale != null) {
      Get.updateLocale(locale);
    } else {
      Get.updateLocale(Get.deviceLocale ?? const Locale('en'));
    }
  }
}
