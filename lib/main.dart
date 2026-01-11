import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization delegates
import 'data/language_provider.dart';
import 'data/theme_provider.dart';
import 'router/app_router.dart'; // Re-add GoRouter provider import
import 'localization.dart'; // Import your translations

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX localization before runApp
  Get.locale = const Locale('en'); // Default to English
  Get.fallbackLocale = const Locale('en');
  Get.addTranslations(AppTranslations().keys);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);

    ref.listen<Locale?>(languageProvider, (previous, next) {
      if (next != null) {
        Get.updateLocale(next);
      } else {
        Get.updateLocale(Get.deviceLocale ?? const Locale('en'));
      }
    });

    // Set initial locale for GetX based on currentLocale (from shared_preferences)
    // This ensures Get.locale is consistent with user's saved preference after app starts
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
        brightness = null; // Let CupertinoApp decide based on system
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
      locale: Get.locale, // Use GetX's managed locale
      theme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: CupertinoColors.activeBlue,
      ),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
