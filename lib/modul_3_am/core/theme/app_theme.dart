import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}