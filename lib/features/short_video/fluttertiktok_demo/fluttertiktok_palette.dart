import 'package:flutter/material.dart';

/// Colors, sizes and text styles ported from the source
/// `flutter_tiktok/lib/style/style.dart`.
class FlutterTiktokPalette {
  const FlutterTiktokPalette._();

  static const Color orange = Color(0xffFFC459);
  static const Color yellow = Color(0xffF1E300);
  static const Color green = Color(0xff7ED321);
  static const Color red = Color(0xffEB3838);
  static const Color darkGray = Color(0xff4A4A4A);
  static const Color gray = Color(0xff9b9b9b);
  static const Color lightGray = Color(0xfff5f5f4);
  static const Color black = Color(0xff000000);
  static const Color white = Color(0xffffffff);
  static const Color back1 = Color(0xff1D1F22);
  static const Color back2 = Color(0xff121314);

  /// The source used `Colors.white.withOpacity(0.66)`.
  static const Color white66 = Color(0xA8FFFFFF);

  static const double avatarSize = 56;
  static const double iconNormal = 24;
  static const double iconBig = 40;
  static const double fontSizeBig = 16;
  static const double fontSizeNormal = 14;
  static const double fontSizeSmall = 12;

  static const TextStyle big = TextStyle(
    fontSize: fontSizeBig,
    fontWeight: FontWeight.w600,
    color: white,
  );
  static const TextStyle bigWithOpacity = TextStyle(
    fontSize: fontSizeBig,
    fontWeight: FontWeight.w600,
    color: white66,
  );
  static const TextStyle normalW = TextStyle(
    fontSize: fontSizeNormal,
    fontWeight: FontWeight.w600,
    color: white,
  );
  static const TextStyle normal = TextStyle(
    fontSize: fontSizeNormal,
    color: white,
  );
  static const TextStyle normalWithOpacity = TextStyle(
    fontSize: fontSizeNormal,
    color: white66,
  );
  static const TextStyle small = TextStyle(
    fontSize: fontSizeSmall,
    color: white,
  );
  static const TextStyle smallWithOpacity = TextStyle(
    fontSize: fontSizeSmall,
    color: white66,
  );
}
