import 'dart:ui';

import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_type.dart';

/// The reader's persisted display/behaviour settings.
///
/// Merges the source's `ReaderConfigEntity` (model_reader_config.dart) and
/// `NovelConfigInfo` (entity_novel_info.dart) — they described the same state —
/// and keeps the defaults declared by `NovelConfigManager`
/// (widget/reader/cache/novel_config_manager.dart): brightness 0.2, font 20,
/// line height 30, paragraph spacing 10, animation mode 仿真, paper colour
/// 0xfffff2cc, padding 10, title height 25, bottom tip height 20.
class FlutterNovelReaderConfig {
  FlutterNovelReaderConfig({
    this.currentAnimationMode = ReaderAnimationType.simulationTurn,
    this.currentCanvasBgColor = defaultCanvasBgColor,
    this.currentPageIndex = 0,
    this.currentChapterIndex = 0,
    this.novelId,
    this.fontSize = defaultFontSize,
    this.lineHeight = defaultLineHeight,
    this.paragraphSpacing = defaultParagraphSpacing,
    this.pageSize,
    this.contentPadding = 10,
    this.titleHeight = 25,
    this.bottomTipHeight = 20,
    this.titleFontSize = 20,
    this.bottomTipFontSize = 20,
    this.brightness = defaultBrightness,
  });

  static const double defaultBrightness = 0.2;
  static const int defaultFontSize = 20;
  static const int defaultLineHeight = 30;
  static const int defaultParagraphSpacing = 10;
  static const Color defaultCanvasBgColor = Color(0xfffff2cc);

  /// 翻页动画类型 — one of [ReaderAnimationType].
  int currentAnimationMode;

  /// 背景色 — the paper colour painted behind every page.
  Color currentCanvasBgColor;

  int currentPageIndex;
  int currentChapterIndex;
  String? novelId;

  int fontSize;
  int lineHeight;
  int paragraphSpacing;

  /// The canvas size the current pagination was computed for.
  Size? pageSize;

  int contentPadding;
  int titleHeight;
  int bottomTipHeight;

  int titleFontSize;
  int bottomTipFontSize;

  /// Screen brightness the reader applies while open.
  double brightness;

  /// The text box height available to a page (mirrors the source's subtraction
  /// of the paddings, the chapter title and the bottom page counter).
  double contentHeight(double pageHeight) =>
      pageHeight -
      (2 * contentPadding) -
      bottomTipHeight -
      titleHeight;

  /// The text box width available to a page.
  double contentWidth(double pageWidth) => pageWidth - (2 * contentPadding);

  FlutterNovelReaderConfig copy() => FlutterNovelReaderConfig(
    currentAnimationMode: currentAnimationMode,
    currentCanvasBgColor: currentCanvasBgColor,
    currentPageIndex: currentPageIndex,
    currentChapterIndex: currentChapterIndex,
    novelId: novelId,
    fontSize: fontSize,
    lineHeight: lineHeight,
    paragraphSpacing: paragraphSpacing,
    pageSize: pageSize,
    contentPadding: contentPadding,
    titleHeight: titleHeight,
    bottomTipHeight: bottomTipHeight,
    titleFontSize: titleFontSize,
    bottomTipFontSize: bottomTipFontSize,
    brightness: brightness,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'currentAnimationMode': currentAnimationMode,
    'currentCanvasBgColor': currentCanvasBgColor.toARGB32(),
    'currentPageIndex': currentPageIndex,
    'currentChapterIndex': currentChapterIndex,
    'novelId': novelId,
    'fontSize': fontSize,
    'lineHeight': lineHeight,
    'paragraphSpacing': paragraphSpacing,
    'pageWidth': pageSize?.width,
    'pageHeight': pageSize?.height,
    'contentPadding': contentPadding,
    'titleHeight': titleHeight,
    'bottomTipHeight': bottomTipHeight,
    'titleFontSize': titleFontSize,
    'bottomTipFontSize': bottomTipFontSize,
    'brightness': brightness,
  };

  factory FlutterNovelReaderConfig.fromMap(Map<String, dynamic> map) {
    final width = _asDouble(map['pageWidth']);
    final height = _asDouble(map['pageHeight']);
    return FlutterNovelReaderConfig(
      currentAnimationMode: _asInt(
        map['currentAnimationMode'],
        ReaderAnimationType.simulationTurn,
      ),
      currentCanvasBgColor: Color(
        _asInt(map['currentCanvasBgColor'], defaultCanvasBgColor.toARGB32()),
      ),
      currentPageIndex: _asInt(map['currentPageIndex'], 0),
      currentChapterIndex: _asInt(map['currentChapterIndex'], 0),
      novelId: map['novelId'] as String?,
      fontSize: _asInt(map['fontSize'], defaultFontSize),
      lineHeight: _asInt(map['lineHeight'], defaultLineHeight),
      paragraphSpacing: _asInt(
        map['paragraphSpacing'],
        defaultParagraphSpacing,
      ),
      pageSize: (width == null || height == null)
          ? null
          : Size(width, height),
      contentPadding: _asInt(map['contentPadding'], 10),
      titleHeight: _asInt(map['titleHeight'], 25),
      bottomTipHeight: _asInt(map['bottomTipHeight'], 20),
      titleFontSize: _asInt(map['titleFontSize'], 20),
      bottomTipFontSize: _asInt(map['bottomTipFontSize'], 20),
      brightness: _asDouble(map['brightness']) ?? defaultBrightness,
    );
  }

  static int _asInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static double? _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }
}
