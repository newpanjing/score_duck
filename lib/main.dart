import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/language_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/game_controller.dart';
import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX localization before runApp
  Get.locale = const Locale('en');
  Get.fallbackLocale = const Locale('en');
  Get.addTranslations(AppTranslations().keys);

  // Initialize controllers
  Get.put(LanguageController());
  Get.put(ThemeController());
  Get.put(GameController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final themeMode = themeController.currentTheme;
      final currentLocale = languageController.currentLocale;

      // Set initial locale for GetX based on currentLocale (from shared_preferences)
      if (currentLocale != null) {
        Get.locale = currentLocale;
      } else {
        Get.locale = Get.deviceLocale ?? const Locale('en');
      }

      Brightness? brightness;
      switch (themeMode) {
        case ThemeMode.light:
          brightness = Brightness.light;
          break;
        case ThemeMode.dark:
          brightness = Brightness.dark;
          break;
        case ThemeMode.system:
          brightness = null;
          break;
      }

      return CupertinoApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppTranslations().keys.keys.map((langCode) {
          if (langCode.contains('-')) {
            final parts = langCode.split('-');
            return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
          }
          return Locale(langCode);
        }).toList(),
        locale: Get.locale,
        theme: CupertinoThemeData(
          brightness: brightness,
          primaryColor: CupertinoColors.activeBlue,
        ),
        routerConfig: Get.find<GameController>().routerConfig,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
