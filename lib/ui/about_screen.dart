import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDark 
          ? CupertinoColors.systemBackground 
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('关于记分鸭'),
        previousPageTitle: '设置',
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.chart_bar_fill,
                  size: 60,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '记分鸭',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '1.0.0';
                return Text(
                  'Version $version',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '记分鸭是一款简单、优雅的比赛记分工具。无论是打牌、下棋还是体育竞技，我们致力于为您提供最流畅的记分体验。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.lock_shield_fill, color: CupertinoColors.activeBlue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        '隐私与安全',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _PrivacyItem(
                    icon: CupertinoIcons.antenna_radiowaves_left_right,
                    text: '完全离线运行，无需互联网权限',
                  ),
                  const _PrivacyItem(
                    icon: CupertinoIcons.nosign,
                    text: '零云端上传，数据不经过服务器',
                  ),
                  const _PrivacyItem(
                    icon: CupertinoIcons.device_phone_portrait,
                    text: '本地安全存储，您的数据仅属于您',
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              '© 2026 ScoreDuck Team',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CupertinoColors.systemGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}