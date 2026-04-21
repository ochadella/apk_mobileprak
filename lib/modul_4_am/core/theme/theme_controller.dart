import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
  ValueNotifier(ThemeMode.light);

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme(bool value) {
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }
}