              import 'package:flutter/cupertino.dart';
              import 'package:package_info_plus/package_info_plus.dart';
              import 'package:get/get.dart';
              
              class AboutScreen extends StatelessWidget {
                const AboutScreen({super.key});              
                @override
                Widget build(BuildContext context) {
                  final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
                  final cardColor = isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white;
                  final borderColor = isDark ? CupertinoColors.systemGrey.withValues(alpha: 0.1) : CupertinoColors.activeBlue.withValues(alpha: 0.1);
              
                  return CupertinoPageScaffold(
                    backgroundColor: CupertinoColors.systemGroupedBackground,
                          navigationBar: CupertinoNavigationBar(
                            middle: Text('settings_about_about_app'.tr),
                            previousPageTitle: 'settings_title'.tr,                    ),
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
                                          Text(
                                            'app_name'.tr,                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 40),
                                            child: Text(
                                              'about_description'.tr,                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, height: 1.5, color: CupertinoColors.systemGrey),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                                          // 隐私与安全
                                          _InfoCard(
                                            title: 'about_privacy_safety'.tr,                              icon: CupertinoIcons.lock_shield_fill,
                              cardColor: cardColor,
                              borderColor: borderColor,
                              children: [
                                                  _InfoItem(
                                                    icon: CupertinoIcons.antenna_radiowaves_left_right,
                                                    text: 'about_privacy_offline'.tr,                                ),
                                                  _InfoItem(
                                                    icon: CupertinoIcons.nosign,
                                                    text: 'about_privacy_no_cloud'.tr,                                ),
                                                  _InfoItem(
                                                    icon: CupertinoIcons.device_phone_portrait,
                                                    text: 'about_privacy_local'.tr,                                ),
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
              