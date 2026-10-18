import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 阅读器外观设置（移植 eso `Profile` 里与阅读相关的字段与落盘方式）。
///
/// eso 把配置放在全局 `Profile` 单例里、整份 JSON 写进一个 key；这里只留
/// 阅读相关的 6 个字段，key 与字段名保持和源实现一致，方便导入旧配置。
class EsoReaderConfig {
  static const String storeKey = 'eso_reader_config';

  /// 源实现 `Profile.newProfile()` 的默认值：字号 18、行高 1.5、段距 15、
  /// 缩进 2 个全角空格、米黄底黑字。
  static const double defaultFontSize = 18.0;
  static const double defaultLineHeight = 1.5;
  static const double defaultParagraphPadding = 15.0;
  static const int defaultTextColor = 0xFF000000;
  static const int defaultBackgroundColor = 0xFFF5DEB3;
  static const int defaultIndentation = 2;

  double fontSize = defaultFontSize;
  double lineHeight = defaultLineHeight;
  double paragraphPadding = defaultParagraphPadding;
  int textColor = defaultTextColor;
  int backgroundColor = defaultBackgroundColor;
  int indentation = defaultIndentation;

  /// 字号区间来自源实现 `novelFontSize.clamp(10, 40)`。
  void setFontSize(double value) => fontSize = value.clamp(10.0, 40.0);

  /// 行高区间来自源实现 `novelHeight.clamp(1, 3)`。
  void setLineHeight(double value) => lineHeight = value.clamp(1.0, 3.0);

  /// 段距：源实现 `> 50` 归 50、`< 0` 归 0。
  void setParagraphPadding(double value) =>
      paragraphPadding = value.clamp(0.0, 50.0);

  /// 缩进区间来自源实现 `novelIndentation.clamp(0, 4)`。
  void setIndentation(int value) => indentation = value.clamp(0, 4);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'novelFontSize': fontSize,
        'novelHeight': lineHeight,
        'novelParagraphPadding': paragraphPadding,
        'novelFontColor': textColor,
        'novelBackgroundColor': backgroundColor,
        'novelIndentation': indentation,
      };

  void applyJson(Map<String, dynamic> json) {
    fontSize = (json['novelFontSize'] as num?)?.toDouble() ?? defaultFontSize;
    lineHeight = (json['novelHeight'] as num?)?.toDouble() ?? defaultLineHeight;
    paragraphPadding = (json['novelParagraphPadding'] as num?)?.toDouble() ??
        defaultParagraphPadding;
    textColor = (json['novelFontColor'] as num?)?.toInt() ?? defaultTextColor;
    backgroundColor = (json['novelBackgroundColor'] as num?)?.toInt() ??
        defaultBackgroundColor;
    indentation = (json['novelIndentation'] as num?)?.toInt() ??
        defaultIndentation;
    setFontSize(fontSize);
    setLineHeight(lineHeight);
    setParagraphPadding(paragraphPadding);
    setIndentation(indentation);
  }

  static EsoReaderConfig fromJson(Map<String, dynamic>? json) {
    final config = EsoReaderConfig();
    if (json != null) config.applyJson(json);
    return config;
  }

  /// 从本地读取配置；读不到或坏数据时回落默认值（源实现的 `fromJson` 行为）。
  Future<EsoReaderConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storeKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) applyJson(decoded);
      } catch (_) {
        // 坏数据直接回落默认值，与源实现 fromJson 的 `?? 默认值` 等价
      }
    }
    return this;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, jsonEncode(toJson()));
  }
}
