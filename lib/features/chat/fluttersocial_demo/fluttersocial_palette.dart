import 'package:flutter/material.dart';

/// Port of the source colour constants (source `lib/utils/colors.dart`).
///
/// The source declares the light/dark/secondary shades as well but never uses
/// them; they are kept verbatim for completeness.
class FlutterSocialPalette {
  const FlutterSocialPalette._();

  static const Color primaryColor = Color(0xFFfbab66);
  static const Color primaryLight = Color(0xFFFF9F59);
  static const Color primaryDark = Color(0xFFFF9F59);

  static const Color secondaryColor = Color(0xFFFF9F59);
  static const Color secondaryLight = Color(0xFFFF9F59);
  static const Color secondaryDark = Color(0xFFFF9F59);

  static const Color gradientStart = Color(0xFFfbab66);
  static const Color gradientEnd = Color(0xFFf7418c);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[gradientStart, gradientEnd],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient chatBubbleGradient = LinearGradient(
    colors: <Color>[Color(0xFFFD60A3), Color(0xFFFF8961)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient chatBubbleGradient2 = LinearGradient(
    colors: <Color>[Color(0xFFf4e3e3), Color(0xFFf4e3e3)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
