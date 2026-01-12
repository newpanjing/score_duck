import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scoreduck/locales/localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/game_controller.dart';
import 'about_screen.dart';
import 'widgets/language_picker.dart';
import 'widgets/welcome_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _sendEmail() async {
    // 触感反馈
    HapticFeedback.mediumImpact();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'newpanjing@icloud.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'settings_support_feedback_subject'.trParams({
          'version': await PackageInfo.fromPlatform().then((value) => value.version),
        }),
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

  String _getCurrentLanguage(Locale? locale) {
    if (locale == null) {
      return '跟随系统';
    }
    if (locale.languageCode == 'en') return 'English';
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'CN') return '中文(简体)';
      if (locale.countryCode == 'TW') return '中文(繁體)';
    }
    if (locale.languageCode == 'es') return 'Español';
    if (locale.languageCode == 'fr') return 'Français';
    if (locale.languageCode == 'de') return 'Deutsch';
    if (locale.languageCode == 'hi') return 'हिन्दी';
    if (locale.languageCode == 'ar') return 'العربية';

    return '跟随系统'; // Fallback
  }

  void _showLanguagePicker(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final currentLocale = languageController.currentLocale;
    final languages = AppTranslations.suppertLanguages;

    final initialIndex = languages.indexWhere((lang) => lang['locale'] == currentLocale);
    final scrollController = FixedExtentScrollController(initialItem: initialIndex >= 0 ? initialIndex : 0);
    // 触感反馈
    HapticFeedback.mediumImpact();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: LanguagePicker(
            scrollController: scrollController,
            languages: languages,
            languageController: languageController,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();
    final currentTheme = themeController.currentTheme;
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);

    return Obx(() {
      final currentLocale = languageController.currentLocale;
      return CupertinoPageScaffold(
        backgroundColor: isDark 
            ? CupertinoColors.systemBackground 
            : CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text('settings_title'.tr),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              CupertinoListSection.insetGrouped(
                header: Text('settings_appearance'.tr),
                children: [
                  CupertinoListTile(
                    leading: Icon(
                          currentTheme == ThemeMode.dark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          color: CupertinoColors.systemOrange,
                          size: 22,
                        ),
                    title: Text('settings_theme_mode'.tr),
                    trailing: CupertinoSlidingSegmentedControl<ThemeMode>(
                      groupValue: currentTheme,
                      children: {
                        ThemeMode.system: Text('settings_theme_system'.tr, style: const TextStyle(fontSize: 13)),
                        ThemeMode.light: Text('settings_theme_light'.tr, style: const TextStyle(fontSize: 13)),
                        ThemeMode.dark: Text('settings_theme_dark'.tr, style: const TextStyle(fontSize: 13)),
                      },
                      onValueChanged: (ThemeMode? value) {
                        if (value != null) {
                          themeController.setTheme(value);
                        }
                        // 触感反馈
                        HapticFeedback.mediumImpact();
                      },
                    ),
                  ),
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.globe,
                      color: CupertinoColors.systemBlue,
                      size: 22,
                    ),
                    title: Text('settings_language_title'.tr),
                    additionalInfo: Text(_getCurrentLanguage(currentLocale)),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text('settings_about_title'.tr),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.info_circle_fill, color: CupertinoColors.systemBlue),
                    title: Text('settings_about_about_app'.tr),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      // 触感反馈
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => const AboutScreen()),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.tag_fill, color: CupertinoColors.systemGreen),
                    title: Text('settings_about_version'.tr),
                    additionalInfo: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) => Text(snapshot.data?.version ?? '1.0.0'),
                    ),
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.hand_thumbsup_fill, color: CupertinoColors.systemYellow),
                    title: Text('settings_welcome_screen'.tr),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => const WelcomeSheet(),
                      );
                    },
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text('settings_support_title'.tr),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.mail, color: CupertinoColors.systemRed),
                    title: Text('settings_support_feedback'.tr),
                    trailing: const CupertinoListTileChevron(),
                    onTap: _sendEmail,
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.app_fill, color: CupertinoColors.systemPurple),
                    title: Text('settings_support_more_apps'.tr),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _launchURL('https://apps.apple.com/developer/id1630712468'),
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.person_solid, color: CupertinoColors.activeBlue),
                    title: Text('settings_support_follow_author'.tr),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _launchURL('https://www.xiaohongshu.com/user/profile/63eddd81000000001001d67c'),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text('settings_danger_zone_title'.tr),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.destructiveRed),
                    title: Text('settings_danger_zone_clear_data'.tr,
                      style: const TextStyle(color: CupertinoColors.destructiveRed)),
                    onTap: () {
                      // 触感反馈
                      HapticFeedback.mediumImpact();
                      showCupertinoDialog(
                        context: context, 
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('settings_danger_zone_clear_confirm_title'.tr),
                          content: Text('settings_danger_zone_clear_confirm_content'.tr),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text('common_cancel'.tr),
                              onPressed: (){
                                // 触感反馈
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: Text('settings_danger_zone_clear_data'.tr),
                              onPressed: () async {
                                // 触感反馈
                                HapticFeedback.mediumImpact();
                                await Get.find<GameController>().clearAll();
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
    });
  }
}
