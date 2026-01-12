import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/language_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/game_controller.dart';
import 'locales/localization.dart';
import 'ui/app_scaffold.dart';
import 'ui/game_detail_screen.dart';
import 'ui/home_screen.dart';
import 'ui/settings_screen.dart';

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

    return Obx(() {
      final themeMode = themeController.currentTheme;

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

      return GetCupertinoApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppTranslations().keys.keys.map((langCode) {
          if (langCode.contains('-')) {
            final parts = langCode.split('-');
            return Locale.fromSubtags(
              languageCode: parts[0],
              scriptCode: parts[1],
            );
          }
          return Locale(langCode);
        }).toList(),
        locale: Get.locale ?? Get.deviceLocale,
        fallbackLocale: const Locale('en_US'),
        theme: CupertinoThemeData(
          brightness: brightness,
          primaryColor: CupertinoColors.activeBlue,
        ),
        getPages: [
          GetPage(name: '/', page: () => const AppScaffold()),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/settings', page: () => const SettingsScreen()),
          GetPage(
            name: '/game/:id',
            page: () {
              final id = Get.parameters['id']!;
              return GameDetailScreen(gameId: id);
            },
          ),
        ],
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
