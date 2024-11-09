import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';

/* - asset: assets/fonts/NotoSansJP/NotoSansJP-Thin.ttf
          weight: 100
        - asset: assets/fonts/NotoSansJP/NotoSansJP-ExtraLight.ttf
          weight: 200
        - asset: assets/fonts/NotoSansJP/NotoSansJP-Light.ttf
          weight: 300
        - asset: assets/fonts/NotoSansJP/NotoSansJP-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoSansJP/NotoSansJP-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoSansJP/NotoSansJP-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/NotoSansJP/NotoSansJP-Bold.ttf
          weight: 700
        - asset: assets/fonts/NotoSansJP/NotoSansJP-ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/NotoSansJP/NotoSansJP-Black.ttf
          weight: 900 */

class ThemeTextStyle {
  final ThemeSize themeSize;
  ThemeTextStyle({required this.themeSize});
  static const primary = 'NotoSansJP';

  TextStyle w100({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w100,
      fontFamily: primary,
    );
  }

  TextStyle w200({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w200,
      fontFamily: primary,
    );
  }

  TextStyle w300({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      fontFamily: primary,
    );
  }

  TextStyle w400(
      {Color color = ThemeColor.text,
      double fontSize = 12.0,
      bool underline = false,
      double? height}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      fontFamily: primary,
      decoration: underline ? TextDecoration.underline : null,
      height: height,
    );
  }

  TextStyle w500({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: primary,
    );
  }

  TextStyle w600({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
    double? height,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: primary,
      height: height,
    );
  }

  TextStyle w700({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontFamily: primary,
    );
  }

  TextStyle w800({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      fontFamily: primary,
    );
  }

  TextStyle w900({
    Color color = ThemeColor.text,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: primary,
    );
  }

  TextStyle tabText() {
    return const TextStyle(
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle numText({
    Color color = ThemeColor.text,
    FontWeight fontWeight = FontWeight.w600,
    double fontSize = 12.0,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle appbarText({bool japanese = false, bool isSmall = false}) {
    return TextStyle(
      color: ThemeColor.text,
      fontSize: isSmall
          ? 16
          : japanese
              ? 20
              : 20,
      fontWeight: FontWeight.w600,
      fontFamily: japanese ? primary : null,
    );
  }
}
