import 'package:flutter/material.dart';

/// Colours of the FlutterSocialAppUIKit static UI demo
/// (source `lib/util/theme_config.dart:3-11`, class `ThemeConfig`).
///
/// The source exposes a light and a dark [ThemeData] and reads the accent from
/// `Theme.of(context).colorScheme.secondary`. The host supplies its own theme,
/// so the port pins the source's light-theme values here and renders the demo
/// with them; this keeps the demo looking like the source instead of inheriting
/// an unrelated host accent.
class FlutterSocialAppUIKitPalette {
  const FlutterSocialAppUIKitPalette._();

  static const Color lightPrimary = Color(0xFFFCFCFF);
  static const Color darkPrimary = Color(0xFF1F1F1F);
  static const Color lightAccent = Colors.blue;
  static const Color darkAccent = Colors.lightBlue;
  static const Color lightBG = Color(0xFFFCFCFF);
  static const Color darkBG = Color(0xFF121212);
  static const Color badgeColor = Colors.red;

  /// Source accent colour in the light theme, which is the theme this demo
  /// renders with (`ThemeConfig.lightAccent`).
  static const Color secondary = lightAccent;

  /// Source `AppBarTheme.titleTextStyle`: 18 px, weight 800, dark foreground.
  static const TextStyle appBarTitle = TextStyle(
    color: darkBG,
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle appBarTitleCentered = appBarTitle;
}
