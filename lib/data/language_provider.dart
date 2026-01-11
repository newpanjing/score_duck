import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends Notifier<Locale?> {
  static const _key = 'locale';

  @override
  Locale? build() {
    Future.microtask(() => _loadLanguage());
    return null; // System default
  }

  Locale? _stringToLocale(String? localeString) {
    if (localeString == null || localeString == 'system') return null;
    if (localeString.contains('_')) {
      final parts = localeString.split('_');
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(localeString);
  }

  String _localeToString(Locale? locale) {
    if (locale == null) return 'system';
    if (locale.scriptCode != null) {
      return '${locale.languageCode}_${locale.scriptCode}';
    }
    return locale.languageCode;
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_key);
      state = _stringToLocale(lang);
    } catch (e) {
      // Fail silently or log
    }
  }

  Future<void> setLanguage(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _localeToString(locale));
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, Locale?>(LanguageNotifier.new);
