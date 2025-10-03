import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/theme.dart';
import '../../core/utils/variables.dart';
import '../../core/values.dart';
import '../router/app_router.dart';

/// アプリケーションのルートウィジェット
///
/// テーマ、ローカライゼーション、ルーティングを設定
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // テーマサイズの取得
    final themeSize = ref.watch(themeSizeProvider(context));

    // ルーターの取得
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ルーティング設定
      routerConfig: router,

      // スキャフォールドメッセンジャー
      scaffoldMessengerKey: scaffoldMessengerKey,

      // ローカライゼーション設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
      ],
      locale: const Locale("ja", "JP"),

      // アプリ情報
      title: appName,
      debugShowCheckedModeBanner: false,

      // テーマ設定
      theme: _buildTheme(themeSize),
    );
  }

  /// アプリケーションテーマの構築
  ThemeData _buildTheme(ThemeSize themeSize) {
    return ThemeData(
      // AppBar テーマ
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        toolbarHeight: themeSize.appbarHeight,
        backgroundColor: ThemeColor.background,
        titleSpacing: themeSize.horizontalPadding,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: ThemeColor.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: ThemeColor.text,
          size: 24,
        ),
      ),

      // Scaffold背景色
      scaffoldBackgroundColor: ThemeColor.background,

      // カラースキーム
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: ThemeColor.beige,
        onPrimary: ThemeColor.text,
        secondary: ThemeColor.highlight,
        onSecondary: ThemeColor.background,
        error: Colors.red,
        onError: ThemeColor.white,
        surface: ThemeColor.button,
        onSurface: ThemeColor.beige,
      ),

      // BottomSheetテーマ
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),

      // Splash効果
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.05),
    );
  }
}