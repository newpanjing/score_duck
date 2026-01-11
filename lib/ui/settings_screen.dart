import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/score_store.dart';
import '../data/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark 
          ? CupertinoColors.systemBackground 
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('设置'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('外观'),
              children: [
                CupertinoListTile(
                  title: const Text('主题模式'),
                  trailing: CupertinoSlidingSegmentedControl<ThemeMode>(
                    groupValue: currentTheme,
                    children: const {
                      ThemeMode.system: Text('系统', style: TextStyle(fontSize: 13)),
                      ThemeMode.light: Text('浅色', style: TextStyle(fontSize: 13)),
                      ThemeMode.dark: Text('深色', style: TextStyle(fontSize: 13)),
                    },
                    onValueChanged: (ThemeMode? value) {
                      if (value != null) {
                        ref.read(themeProvider.notifier).setTheme(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('通用'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.info),
                  title: const Text('关于记分鸭'),
                  additionalInfo: const Text('v1.0.0'),
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
              ],
            ),
             CupertinoListSection.insetGrouped(
              header: const Text('数据'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed,),
                  title: const Text('清除所有数据', style: TextStyle(color: CupertinoColors.destructiveRed),),
                  onTap: () {
                     showCupertinoDialog(
                      context: context, 
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('确认清除'),
                        content: const Text('确定要删除所有比赛记录吗？此操作无法撤销。'),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            child: const Text('取消'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('清除'),
                            onPressed: () async {
                              await ref.read(scoreProvider.notifier).clearAll();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}