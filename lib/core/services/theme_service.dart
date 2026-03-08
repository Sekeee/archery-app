import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();
  
  GetStorage? _storage;
  final _key = 'isDarkMode';
  
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }
  
  void _initStorage() {
    try {
      _storage = GetStorage();
      _loadTheme();
    } catch (e) {
      debugPrint('ThemeService storage init error: $e');
    }
  }
  
  void _loadTheme() {
    try {
      // Default to dark mode if no preference saved
      final isDark = _storage?.read<bool>(_key) ?? true;
      themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
      // Ensure dark mode is saved as default
      if (_storage?.read<bool>(_key) == null) {
        _storage?.write(_key, true);
      }
    } catch (e) {
      debugPrint('ThemeService load error: $e');
    }
  }
  
  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  
  void toggleTheme() {
    themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
    Get.changeThemeMode(themeMode.value);
  }
  
  void _saveTheme() {
    try {
      _storage?.write(_key, isDarkMode);
    } catch (e) {
      debugPrint('ThemeService save error: $e');
    }
  }
  
  void setDarkMode(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    Get.changeThemeMode(themeMode.value);
  }
}
