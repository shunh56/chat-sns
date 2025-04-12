import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Images {
  static const instagramIcon = 'assets/images/icons/instagram.png';
  static const xIcon = 'assets/images/icons/x.png';
  static const lineIcon = 'assets/images/icons/line.png';
}

class ThemeColor {
  // 背景色のグラデーション
  static const background = Color(0xFF151515); // メイン背景色
  static const surface = Color(0xFF1E1E1E); // カード・要素の背景
  static const accent = Color(0xFF1E1E1E); // 要素の強調背景

  // 境界線と分離要素
  static const stroke = Color(0xFF303030);
  static const divider = Color(0xFF383838); // 区切り線

  // テキストカラー
  static const text = Color(0xFFF0F0F0); // メインテキスト
  static const textSecondary = Color(0xFFB0B0B0); // セカンダリーテキスト
  static const textTertiary = Color(0xFF808080); // 補足テキスト

  // アクセントカラー
  static const primary = Color(0xFF3B82F6); // プライマリーアクセント（青）
  static const primaryLight = Color(0xFF60A5FA); // プライマリーライト
  static const secondary = Color(0xFF10B981); // セカンダリーアクセント（緑）

  // 状態表示
  static const success = Color(0xFF34D399); // 成功
  static const warning = Color(0xFFFBBF24); // 警告
  static const error = Color(0xFFEF4444); // エラー

  // インタラクティブ要素
  static const hover = Color(0xFF2A2A2A); // ホバー状態
  static const pressed = Color(0xFF323232); // プレス状態
  static const selected = Color(0xFF3B82F6); // 選択状態

  // 特殊要素
  static const overlay = Color(0x80000000); // オーバーレイ
  static const shimmer = Color(0xFF242424); // ローディングシマー効果

  //
  //
  //static const background = Color(0xFF080808);
  //static const accent = Color(0xFF0F0F0F);

  static const white = Color(0xFFFFFFFF);
  static const beige = Color(0xFFC0C0C0);
  static const icon = Color(0xFFcacaca);
  static const button = Color(0xFFD0D0D0);
  static const headline = Color(0xFFACACAC);
  static const highlight = Colors.blue;
  static const subText = Color(0xFF808080);



  //new 
  static const cardColor = Color(0xFF1F1F1F);
  static const cardBorderColor = Color(0xFF3E3E3E);
  static const cardSecondaryColor = Color(0xFF9A9A9A);

}

/*

class ThemeColor {
  //static const textLight = Color(0xFFC7C7C7);
  //static const textGrey = Color(0xFF999999);
  //static const primary = Color.fromARGB(255, 244, 242, 236);
  //static const secondary = Color.fromARGB(255, 152, 182, 110);
  //static const onSecondary = Color.fromARGB(255, 166, 158, 152);
  //static const tertiary = Color.fromARGB(255, 12, 104, 71);
  static const error = Color.fromARGB(255, 239, 68, 68);
  //static const onError = Colors.white;
  //static const surface = Colors.white; //これが背景の画像
  //static const onSurface = Color.fromARGB(255, 72, 71, 66); //背景の上に乗っかる文字の色

/*
  static const background = Color(0xFFF7F7F7);
  static const white = Color(0xFFFFFFFF);
  static const beige = Color(0xFFE9E4D7);
  static const icon = Color(0xFF372F2C);
  static const button = Color(0xFF473A39);
  static const text = Color(0xFF372F2C);
  static const headline = Color(0xFF413E3B);
  static const highlight = Color(0xFF916B51); */

  static const background = Color(0xFF080808);
  static const accent = Color(0xFF0F0F0F);
  static const stroke = Color(0xFF202020);
  static const white = Color(0xFFFFFFFF);
  static const beige = Color(0xFFC0C0C0);
  static const icon = Color(0xFFcacaca);
  static const button = Color(0xFFD0D0D0);

  static const headline = Color(0xFFACACAC);
  static const highlight = Colors.blue;

  static const text = Color(0xFFDDDDDD);
  static const subText = Color(0xFF808080);
}
*/

final themeSizeProvider =
    Provider.family<ThemeSize, BuildContext>((Ref ref, BuildContext context) {
  final themeSize = ThemeSize(size: MediaQuery.of(context).size);
  return themeSize;
});

/*ui.Size getDeviceSize() {
  // ignore: deprecated_member_use
  final physicalScreenSize = ui.window.physicalSize;
  // ignore: deprecated_member_use
  final devicePixelRatio = ui.window.devicePixelRatio;
  final logicalScreenSize = ui.Size(
    physicalScreenSize.width / devicePixelRatio,
    physicalScreenSize.height / devicePixelRatio,
  );
  return logicalScreenSize;
} */

class ThemeSize {
  final Size size;
  ThemeSize({required this.size});

  double get screenWidth => size.width;
  double get screenHeight => size.height;

  double get appbarHeight => kToolbarHeight - 12;

  //appbar, titles, regularpadding
  double get horizontalPadding => size.width * 0.02;

  double get verticalSpaceLarge => 24;
  double get verticalSpaceMedium => 12;
  double get verticalSpaceSmall => 8;
  double get verticalSpaceTiny => 4;

  double get horizontalPaddingLarge => size.width * 0.08;
  double get verticalPaddingLarge => size.width * 0.07;
  double get horizontalPaddingMedium => size.width * 0.04;
  double get verticalPaddingMedium => size.width * 0.035;
  double get verticalPaddingSmall => size.width * 0.025;
  double get horizontalTextSpaceMedium => 12;
  double get horizontalTextSpaceSmall => 8;
  double get horizontalTextSpaceTiny => 4;

  double get verticalSpaceExtraLarge => 48;

  double get cornerRadiusLarge => 32;
  double get cornerRadiusMedium => 24;
  double get cornerRadiusSmall => 12;

  double get horizontalTextPaddingMedium => 20;
  double get verticalTextPaddingMedium => 8;

  double get bookListHorizontalSpace => size.width * 0.08;
  double get bookWidth =>
      (screenWidth - 2 * horizontalPaddingLarge - bookListHorizontalSpace) / 2;
  double get bookAspectRatio => 0.7;

  double get backButtonSize => 30.0;
  double get userIconRadiusMedium => 16;
  double get userIconRadiusSmall => 12;
}

class ThemeFont {
  static const primary = 'NotoSansJP';
}

/*
class L10n {
  static const appName = 'Colub';
  static const bookColub = '読書会';
}
 */