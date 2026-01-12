import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.scrollController,
    required this.languages,
    required this.languageController,
  });

  final FixedExtentScrollController scrollController;
  final List<Map<String, dynamic>> languages;
  final LanguageController languageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('common_cancel'.tr),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('common_done'.tr),
                onPressed: () {
                  final selectedIndex = scrollController.selectedItem;
                  languageController.setLanguage(languages[selectedIndex]['locale'] as Locale?);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: CupertinoPicker(
            scrollController: scrollController,
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
            },
            children: languages.map((lang) {
              return Center(
                child: Text(
                  lang['name'] as String,
                  style: const TextStyle(fontSize: 22.0),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
