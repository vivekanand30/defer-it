import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A4AFC),
        brightness: Brightness.dark,
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: base.appBarTheme.copyWith(centerTitle: true),
    );
  }
}
