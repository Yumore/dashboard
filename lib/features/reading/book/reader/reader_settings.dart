import 'package:dashboard/features/reading/book/util/book_local_store.dart';
import 'package:flutter/material.dart';

/// Solid paper theme for the reader canvas (WeChat Reading style).
enum PaperTheme { white, cream, green, night }

/// Reader typography / paper / page-turn preferences.
///
/// Host port of `book/lib/common/read_setting.dart`. Deliberate deviations:
/// * no `AppColors` / `Screen` dependency — the paper palette lives here and
///   screen metrics are pushed in through [configureScreen];
/// * no `flustars` — [SpUtil] is the local shared_preferences wrapper.
class ReaderSettings {
  ReaderSettings._();

  // ---- preference keys ----
  static const String darkKey = 'dark';
  static const String fontSizeKey = 'FONT_SIZE';
  static const String lineHeightKey = 'LINE_HEIGHT';
  static const String letterSpaceKey = 'LATTER_SPACE';
  static const String paragraphKey = 'paragraph';
  static const String pageDisKey = 'pageDis';
  static const String paperKey = 'paper_theme';
  static const String useSolidPaperKey = 'use_solid_paper';
  static const String fontMigratedKey = 'font_size_migrated_v19';
  static const String fontNameKey = 'fontName';
  static const String fontPathKey = 'fontPath';
  static const String pageTurnModeKey = 'pageTurnMode';
  static const String tempWKey = 'temp_w';
  static const String tempHKey = 'temp_h';

  /// Bundled CJK face used when the user has not picked a custom font.
  static const String defaultFontFamily = 'HarmonyOSSansSC';
  static const String defaultFontAsset =
      'assets/fonts/HarmonyOS_Sans_SC_Regular.ttf';

  static String _bundledFontPath = '';

  /// Legacy texture backgrounds (optional advanced skins).
  static const List<String> bgImg = [
    'QR_bg_1.jpg',
    'QR_bg_2.jpg',
    'QR_bg_3.jpg',
    'QR_bg_5.jpg',
    'QR_bg_7.png',
    'QR_bg_8.png',
    'QR_bg_4.jpg',
  ];

  static const List<PaperTheme> solidPapers = [
    PaperTheme.white,
    PaperTheme.cream,
    PaperTheme.green,
    PaperTheme.night,
  ];

  // ---- screen metrics (pushed by the reader page) ----
  static double _screenWidth = 360;
  static double _screenHeight = 640;
  static double _topSafeHeight = 0;
  static double _bottomSafeHeight = 0;

  static double get screenWidth => _screenWidth;

  static double get screenHeight => _screenHeight;

  static double get topSafeHeight => _topSafeHeight;

  static double get bottomSafeHeight => _bottomSafeHeight;

  static void configureScreen({
    required double width,
    required double height,
    double topSafe = 0,
    double bottomSafe = 0,
  }) {
    if (width > 0) _screenWidth = width;
    if (height > 0) _screenHeight = height;
    _topSafeHeight = topSafe;
    _bottomSafeHeight = bottomSafe;
  }

  // ---- paper palette ----
  static const Color paperWhite = Color(0xFFFDFDFD);
  static const Color paperCream = Color(0xFFF5EFE0);
  static const Color paperGreen = Color(0xFFCCE8CF);
  static const Color paperNight = Color(0xFF1A1A1A);
  static const Color inkOnLight = Color(0xFF2B2B2B);
  static const Color inkOnGreen = Color(0xFF1F3A24);
  static const Color inkOnNight = Color(0xFFB8B8B8);
  static const Color textSecondary = Color(0xFF8A8A8A);

  static bool isDark() => SpUtil.getBool(darkKey);

  static String paperLabel(PaperTheme t) {
    switch (t) {
      case PaperTheme.white:
        return '白';
      case PaperTheme.cream:
        return '米';
      case PaperTheme.green:
        return '绿';
      case PaperTheme.night:
        return '夜';
    }
  }

  static Color paperColor(PaperTheme t) {
    switch (t) {
      case PaperTheme.white:
        return paperWhite;
      case PaperTheme.cream:
        return paperCream;
      case PaperTheme.green:
        return paperGreen;
      case PaperTheme.night:
        return paperNight;
    }
  }

  static Color inkColor(PaperTheme t) {
    switch (t) {
      case PaperTheme.white:
      case PaperTheme.cream:
        return inkOnLight;
      case PaperTheme.green:
        return inkOnGreen;
      case PaperTheme.night:
        return inkOnNight;
    }
  }

  static Color metaColor(PaperTheme t) {
    switch (t) {
      case PaperTheme.night:
        return const Color(0x66FFFFFF);
      case PaperTheme.green:
        return inkOnGreen.withValues(alpha: 0.55);
      default:
        return textSecondary;
    }
  }

  static PaperTheme getPaperTheme() {
    final name = SpUtil.getString(paperKey, defValue: 'cream');
    return PaperTheme.values.firstWhere(
      (e) => e.name == name,
      orElse: () => PaperTheme.cream,
    );
  }

  static void setPaperTheme(PaperTheme t) {
    SpUtil.putString(paperKey, t.name);
    if (t == PaperTheme.night) {
      SpUtil.putBool(darkKey, true);
    } else if (SpUtil.getBool(darkKey)) {
      SpUtil.putBool(darkKey, false);
    }
  }

  static bool useSolidPaper() =>
      SpUtil.getBool(useSolidPaperKey, defValue: true);

  static void setUseSolidPaper(bool v) => SpUtil.putBool(useSolidPaperKey, v);

  /// One-shot: old default 26 → calm 19 (line height 1.8 → 1.7).
  static void migrateFontDefaultsIfNeeded() {
    if (SpUtil.getBool(fontMigratedKey)) return;
    if (SpUtil.getDouble(fontSizeKey, defValue: 26) == 26) {
      SpUtil.putDouble(fontSizeKey, 19);
    }
    if (SpUtil.getDouble(lineHeightKey, defValue: 1.8) == 1.8) {
      SpUtil.putDouble(lineHeightKey, 1.7);
    }
    SpUtil.putBool(fontMigratedKey, true);
  }

  static double getFontSize() {
    migrateFontDefaultsIfNeeded();
    return SpUtil.getDouble(fontSizeKey, defValue: 19);
  }

  static void setFontSize(double fontSize) =>
      SpUtil.putDouble(fontSizeKey, fontSize);

  static void calcFontSize(double delta) =>
      setFontSize(getFontSize() + delta);

  static double getLineHeight() {
    migrateFontDefaultsIfNeeded();
    return SpUtil.getDouble(lineHeightKey, defValue: 1.7);
  }

  static void setLineHeight(double v) => SpUtil.putDouble(lineHeightKey, v);

  static void addLineHeight() => setLineHeight(getLineHeight() + .1);

  static void subLineHeight() => setLineHeight(getLineHeight() - .1);

  static double getLetterSpace() =>
      SpUtil.getDouble(letterSpaceKey, defValue: 3.0);

  static void setLetterSpace(double v) => SpUtil.putDouble(letterSpaceKey, v);

  static void addLetterSpace() => setLetterSpace(getLetterSpace() + 1);

  static void subLetterSpace() => setLetterSpace(getLetterSpace() - 1);

  static double getParagraph() => SpUtil.getDouble(paragraphKey, defValue: .8);

  static void setParagraph(double v) => SpUtil.putDouble(paragraphKey, v);

  static void addParagraph() => setParagraph(getParagraph() + .1);

  static void subParagraph() => setParagraph(getParagraph() - .1);

  static int getPageDis() => SpUtil.getInt(pageDisKey, defValue: 20);

  static void setPageDis(int s) => SpUtil.putInt(pageDisKey, s);

  static void calcPageDis(int delta) => setPageDis(getPageDis() + delta);

  static int getPageTurnMode() => SpUtil.getInt(pageTurnModeKey, defValue: 0);

  static void setPageTurnMode(int mode) =>
      SpUtil.putInt(pageTurnModeKey, mode.clamp(0, 3));

  static String getFontFamily() {
    final name = SpUtil.getString(fontNameKey);
    if (name.isEmpty) return defaultFontFamily;
    return name;
  }

  static void setFontFamily(String name) => SpUtil.putString(
        fontNameKey,
        name.isEmpty ? defaultFontFamily : name,
      );

  static void setBundledFontPath(String path) => _bundledFontPath = path;

  static String get bundledFontPath => _bundledFontPath;

  static String getFontPath() {
    final custom = SpUtil.getString(fontPathKey);
    if (custom.isNotEmpty) return custom;
    final family = getFontFamily();
    if (family == defaultFontFamily || family.isEmpty) {
      return _bundledFontPath;
    }
    return '';
  }

  static void setFontPath(String path) => SpUtil.putString(fontPathKey, path);

  static void clearFontPath() => SpUtil.putString(fontPathKey, '');

  static double getTempW() => SpUtil.getDouble(tempWKey);

  static void setTempW(double w) => SpUtil.putDouble(tempWKey, w);

  static double getTempH() => SpUtil.getDouble(tempHKey);

  static void setTempH(double h) => SpUtil.putDouble(tempHKey, h);

  // ---- layout chrome ----

  /// Height of the chapter-title chrome band (below the status / safe area).
  static const double contentTopChrome = 36;

  /// Height of the time / page-number chrome band (above the bottom safe area).
  static const double contentBottomChrome = 36;

  /// Gap between chrome labels and body text (applied at both ends).
  static const double contentChromeGap = 12;

  /// Pager ABI this layout contract implements (semantic lines).
  static const int abiVersion = 3;

  static double chapterTitleBandTop() => _topSafeHeight;

  static double bottomChromeBandTop() =>
      _screenHeight - _bottomSafeHeight - contentBottomChrome;

  static double contentTopInset() =>
      chapterTitleBandTop() + contentTopChrome + contentChromeGap;

  static double contentBottomInset() =>
      contentBottomChrome + _bottomSafeHeight + contentChromeGap;

  /// Collect layout metrics used by pagination and paint.
  static Map<String, dynamic> layoutParams({
    bool shouldJustifyHeight = false,
  }) {
    final fontSize = getFontSize();
    final lineHeight = getLineHeight();
    final topPad = contentTopInset();
    final bottomPad = contentBottomInset();
    final rawH = _screenHeight - topPad - bottomPad;
    final boxH =
        rawH > 120 ? rawH : (_screenHeight * 0.7).clamp(200.0, 2000.0);
    final boxW = _screenWidth > 0 ? _screenWidth : 360.0;
    return <String, dynamic>{
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'paragraph': getParagraph() * fontSize * lineHeight,
      'padH': getPageDis().toDouble(),
      'boxW': boxW,
      'boxH': boxH,
      'fontFamily': getFontFamily(),
      'fontPath': getFontPath(),
      'shouldJustifyHeight': shouldJustifyHeight,
      'abi': abiVersion,
      'textAlign': 'justify',
    };
  }
}
