import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'constants/tempo_colors.dart';
import 'constants/tempo_text_styles.dart';
import 'pages/tempo_home_page.dart';

/// Tempoアプリのメイン画面
/// 既存アプリから独立したv2 UI
class TempoApp extends ConsumerWidget {
  const TempoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tempo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark, // デフォルトはダークモード
      home: const TempoHomePage(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: TempoColors.primary,
      scaffoldBackgroundColor: TempoColors.backgroundLight,
      cardColor: TempoColors.surfaceLight,
      dividerColor: TempoColors.textTertiary.withOpacity(0.1),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: TempoColors.surfaceLight,
        foregroundColor: TempoColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TempoColors.surfaceLight,
        selectedItemColor: TempoColors.primary,
        unselectedItemColor: TempoColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // TextTheme
      textTheme: TextTheme(
        displayLarge: TempoTextStyles.display1.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        displayMedium: TempoTextStyles.display2.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        headlineLarge: TempoTextStyles.headline1.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        headlineMedium: TempoTextStyles.headline2.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        headlineSmall: TempoTextStyles.headline3.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        bodyLarge: TempoTextStyles.bodyLarge.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        bodyMedium: TempoTextStyles.bodyMedium.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        bodySmall: TempoTextStyles.bodySmall.copyWith(
          color: TempoColors.textSecondary,
        ),
        labelLarge: TempoTextStyles.buttonLarge.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        labelMedium: TempoTextStyles.buttonMedium.copyWith(
          color: TempoColors.textPrimaryLight,
        ),
        labelSmall: TempoTextStyles.caption.copyWith(
          color: TempoColors.textSecondary,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TempoColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: TempoColors.primary,
            width: 2,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TempoColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TempoTextStyles.buttonMedium,
        ),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: TempoColors.primary,
        secondary: TempoColors.secondary,
        tertiary: TempoColors.accent,
        surface: TempoColors.surfaceLight,
        background: TempoColors.backgroundLight,
        error: TempoColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: TempoColors.textPrimaryLight,
        onBackground: TempoColors.textPrimaryLight,
        onError: Colors.white,
      ),

      // Font Family
      fontFamily: TempoTextStyles.fontFamily,

      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TempoColors.primary,
      scaffoldBackgroundColor: TempoColors.background,
      cardColor: TempoColors.surface,
      dividerColor: TempoColors.textTertiary.withOpacity(0.1),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: TempoColors.surface,
        foregroundColor: TempoColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TempoColors.surface,
        selectedItemColor: TempoColors.primary,
        unselectedItemColor: TempoColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // TextTheme
      textTheme: TextTheme(
        displayLarge: TempoTextStyles.display1.copyWith(
          color: TempoColors.textPrimary,
        ),
        displayMedium: TempoTextStyles.display2.copyWith(
          color: TempoColors.textPrimary,
        ),
        headlineLarge: TempoTextStyles.headline1.copyWith(
          color: TempoColors.textPrimary,
        ),
        headlineMedium: TempoTextStyles.headline2.copyWith(
          color: TempoColors.textPrimary,
        ),
        headlineSmall: TempoTextStyles.headline3.copyWith(
          color: TempoColors.textPrimary,
        ),
        bodyLarge: TempoTextStyles.bodyLarge.copyWith(
          color: TempoColors.textPrimary,
        ),
        bodyMedium: TempoTextStyles.bodyMedium.copyWith(
          color: TempoColors.textPrimary,
        ),
        bodySmall: TempoTextStyles.bodySmall.copyWith(
          color: TempoColors.textSecondary,
        ),
        labelLarge: TempoTextStyles.buttonLarge.copyWith(
          color: TempoColors.textPrimary,
        ),
        labelMedium: TempoTextStyles.buttonMedium.copyWith(
          color: TempoColors.textPrimary,
        ),
        labelSmall: TempoTextStyles.caption.copyWith(
          color: TempoColors.textSecondary,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TempoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: TempoColors.primary,
            width: 2,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TempoColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TempoTextStyles.buttonMedium,
        ),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: TempoColors.primary,
        secondary: TempoColors.secondary,
        tertiary: TempoColors.accent,
        surface: TempoColors.surface,
        background: TempoColors.background,
        error: TempoColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: TempoColors.textPrimary,
        onBackground: TempoColors.textPrimary,
        onError: Colors.white,
      ),

      // Font Family
      fontFamily: TempoTextStyles.fontFamily,

      useMaterial3: true,
    );
  }
}
