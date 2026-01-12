import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'en_us.dart';
import 'zh_hans.dart';
import 'zh_hant.dart';
import 'es_es.dart';
import 'fr.dart';
import 'de.dart';
import 'hi.dart';
import 'ar.dart';

class AppTranslations extends Translations {
  static final suppertLanguages = [
    {'locale': null, 'name': '跟随系统'},
    {'locale': const Locale('en'), 'name': 'English'},
    {
      'locale': const Locale('zh', 'CN'),
      'name': '中文(简体)',
    },
    {
      'locale': const Locale('zh', 'TW'),
      'name': '中文(繁體)',
    },
    {'locale': const Locale('es'), 'name': 'Español'},
    {'locale': const Locale('fr'), 'name': 'Français'},
    {'locale': const Locale('de'), 'name': 'Deutsch'},
    {'locale': const Locale('hi'), 'name': 'हिन्दी'},
    {'locale': const Locale('ar'), 'name': 'العربية'},
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': EnUsTranslations.keys,
    'zh_CN': ZhHansTranslations.keys,
    'zh_TW': ZhHantTranslations.keys,
    'es_ES': EsEsTranslations.keys,
    'fr': FrTranslations.keys,
    'de': DeTranslations.keys,
    'hi': HiTranslations.keys,
    'ar': ArTranslations.keys,
  };
}
