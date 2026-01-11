import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
      query: _encodeQueryParameters(<String, String>{
        'subject': '记分鸭意见反馈',
      }),
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email client');
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white;
    final borderColor = isDark ? CupertinoColors.systemGrey.withValues(alpha: 0.1) : CupertinoColors.activeBlue.withValues(alpha: 0.1);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('关于记分鸭'),
        previousPageTitle: '设置',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.chart_bar_fill,
                    size: 50,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '记分鸭',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return Text(
                    'Version $version',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  '记分鸭是一款简单、优雅的比赛记分工具。致力于为您提供最纯净、高效的记分体验。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: CupertinoColors.systemGrey),
                ),
              ),
              const SizedBox(height: 32),
              
              // 隐私与安全
              _InfoCard(
                title: '隐私与安全',
                icon: CupertinoIcons.lock_shield_fill,
                cardColor: cardColor,
                borderColor: borderColor,
                children: const [
                  _InfoItem(
                    icon: CupertinoIcons.antenna_radiowaves_left_right,
                    text: '完全离线运行，无需互联网权限',
                  ),
                  _InfoItem(
                    icon: CupertinoIcons.nosign,
                    text: '零云端上传，数据不经过服务器',
                  ),
                  _InfoItem(
                    icon: CupertinoIcons.device_phone_portrait,
                    text: '本地安全存储，您的数据仅属于您',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 反馈与支持
              _InfoCard(
                title: '反馈与支持',
                icon: CupertinoIcons.heart_fill,
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  _LinkItem(
                    icon: CupertinoIcons.mail,
                    text: '意见反馈',
                    onTap: _sendEmail,
                  ),
                  _LinkItem(
                    icon: CupertinoIcons.app,
                    text: '更多应用',
                    onTap: () => _launchURL('https://apps.apple.com/developer/id123456789'),
                  ),
                  _LinkItem(
                    icon: CupertinoIcons.person,
                    text: '关注作者',
                    onTap: () => _launchURL('https://github.com/newpanjing'),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              const Text(
                '© 2026 ScoreDuck Team',
                style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey2),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color cardColor;
  final Color borderColor;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: CupertinoColors.activeBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: CupertinoColors.systemGrey2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _LinkItem({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: CupertinoColors.activeBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: CupertinoColors.label),
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey3),
          ],
        ),
      ),
    );
  }
}
