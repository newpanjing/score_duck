import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/theme_provider.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: ScoreDuckApp()));
}

class ScoreDuckApp extends ConsumerWidget {
  const ScoreDuckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return CupertinoApp.router(
      title: '记分鸭',
      theme: CupertinoThemeData(
        brightness: themeMode == ThemeMode.system
            ? null // follow system
            : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light),
        primaryColor: CupertinoColors.activeBlue,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
