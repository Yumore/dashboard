import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';

/// Theme of the ported FlutterSocialAppUIKit demo.
///
/// Source `lib/util/theme_config.dart`: the app supplies its own
/// `ThemeData.light()` with a near-white background, a blue accent and an
/// 18 px / weight-800 app-bar title. The host keeps its own theme, so the demo
/// wraps each of its routes in this light theme and keeps looking like the
/// source regardless of the host's brightness setting.
class FlutterSocialAppUIKitTheme {
  const FlutterSocialAppUIKitTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: FlutterSocialAppUIKitPalette.lightAccent,
            brightness: Brightness.light,
          ).copyWith(
            secondary: FlutterSocialAppUIKitPalette.lightAccent,
            surface: FlutterSocialAppUIKitPalette.lightBG,
          ),
      scaffoldBackgroundColor: FlutterSocialAppUIKitPalette.lightBG,
      appBarTheme: const AppBarTheme(
        backgroundColor: FlutterSocialAppUIKitPalette.lightBG,
        foregroundColor: FlutterSocialAppUIKitPalette.darkBG,
        elevation: 0.0,
        titleTextStyle: FlutterSocialAppUIKitPalette.appBarTitle,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FlutterSocialAppUIKitPalette.lightBG,
        selectedItemColor: FlutterSocialAppUIKitPalette.darkBG,
        unselectedItemColor: Color(0xFF9E9E9E),
      ),
    );
  }
}
