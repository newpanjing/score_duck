import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/score_store.dart';
import '../data/theme_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'newpanjing@icloud.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'ScoreDuckAPP Feedback from ${await PackageInfo.fromPlatform().then((value) => value.version)}',
      }),
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email client');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

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
                  leading: Icon(
                    currentTheme == ThemeMode.dark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                    color: CupertinoColors.systemOrange,
                    size: 22,
                  ),
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
              header: const Text('关于'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.info_circle_fill, color: CupertinoColors.systemBlue),
                  title: const Text('关于记分鸭'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.tag_fill, color: CupertinoColors.systemGreen),
                  title: const Text('当前版本'),
                  additionalInfo: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) => Text(snapshot.data?.version ?? '1.0.0'),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('反馈与支持'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.mail, color: CupertinoColors.systemRed),
                  title: const Text('意见反馈'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _sendEmail,
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.app_fill, color: CupertinoColors.systemPurple),
                  title: const Text('更多应用'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _launchURL('https://apps.apple.com/developer/id1630712468'), // 替换为您的开发者链接
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_solid, color: CupertinoColors.activeBlue),
                  title: const Text('关注作者'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _launchURL('https://www.xiaohongshu.com/user/profile/63eddd81000000001001d67c'), // 替换为您的个人主页
                ),
              ],
            ),
             CupertinoListSection.insetGrouped(
              header: const Text('危险区域'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.destructiveRed),
                  title: const Text('清除所有数据', style: TextStyle(color: CupertinoColors.destructiveRed)),
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
                              if (context.mounted) Navigator.pop(context);
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
