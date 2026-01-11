import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _key = 'theme_mode';
  static ThemeController get to => Get.find();

  final Rx<ThemeMode> _currentTheme = ThemeMode.system.obs;
  ThemeMode get currentTheme => _currentTheme.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_key);
      if (index != null) {
        _currentTheme.value = ThemeMode.values[index];
      }
    } catch (e) {
      // Fail silently or log
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    _currentTheme.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }
}
