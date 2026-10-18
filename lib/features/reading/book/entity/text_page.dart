import 'package:dashboard/features/reading/book/entity/text_line.dart';

/// One screen page of composed [TextLine]s (ABI v3, hand-written JSON).
class TextPage {
  final List<TextLine> lines;

  /// Content-box height occupied by this page (for scroll tiles).
  final double height;

  /// 0-based page index within the chapter layout.
  final int pageIndex;

  /// UTF-16-ish content range is not used; these are UTF-8 byte offsets from
  /// the native pager (0 when produced by Dart fallback).
  final int charStart;
  final int charEnd;

  const TextPage(
    this.lines,
    this.height, {
    this.pageIndex = 0,
    this.charStart = 0,
    this.charEnd = 0,
  });

  factory TextPage.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    return TextPage(
      rawLines is List
          ? rawLines
              .whereType<Map>()
              .map((e) => TextLine.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const <TextLine>[],
      _d(json['height']),
      pageIndex: _i(json['pageIndex']),
      charStart: _i(json['charStart']),
      charEnd: _i(json['charEnd']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'lines': lines.map((e) => e.toJson()).toList(),
        'height': height,
        'pageIndex': pageIndex,
        'charStart': charStart,
        'charEnd': charEnd,
      };
}

int _i(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _d(Object? v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
