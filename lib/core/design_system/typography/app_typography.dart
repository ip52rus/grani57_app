import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Manrope';

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 42,
    height: 48 / 42,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}
