import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Container(
                  width: 250,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF2C2C2E)
                            : CupertinoColors.white)
                        .withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: -5,
                      ),
                    ],
                    border: Border.all(
                      color: (isDark
                              ? CupertinoColors.white
                              : CupertinoColors.systemGrey)
                          .withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _BottomBarItem(
                              icon: CupertinoIcons.home,
                              label: 'home_tab_title'.tr,
                              isSelected: navigationShell.currentIndex == 0,
                              onTap: () => _onTap(context, 0),
                            ),
                          ),
                          Expanded(
                            child: _BottomBarItem(
                              icon: CupertinoIcons.settings,
                              label: 'settings_tab_title'.tr,
                              isSelected: navigationShell.currentIndex == 1,
                              onTap: () => _onTap(context, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}