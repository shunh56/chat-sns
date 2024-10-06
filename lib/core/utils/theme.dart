import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Images {
  static const instagramIcon = 'assets/images/icons/instagram.png';
  static const xIcon = 'assets/images/icons/x.png';
  static const lineIcon = 'assets/images/icons/line.png';
}

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
  double get horizontalPadding => size.width * 0.04;

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