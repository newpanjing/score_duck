import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../ui/app_scaffold.dart';
import '../ui/home_screen.dart';
import '../ui/game_detail_screen.dart';
import '../ui/settings_screen.dart';

// Keys for the navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    // StatefulShellRoute for the Bottom Navigation Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'game/:id',
                  parentNavigatorKey: _rootNavigatorKey, // Hide bottom bar
                  builder: (context, state) {
                    final String id = state.pathParameters['id']!;
                    return GameDetailScreen(gameId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Settings
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);