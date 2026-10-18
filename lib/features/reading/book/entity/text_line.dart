/// One visual line of chapter text after pagination.
///
/// ABI v3 contract: **semantic layout only**.
/// - [top]/[height] are page-local vertical metrics for stacking lines.
/// - [justify]/[targetWidth] express alignment intent; Flutter's Skia
///   [TextPainter] computes the final letterSpacing at paint time.
/// - Do **not** treat any field as a cosmic-text glyph coordinate.
///
/// Hand-written JSON mapping replaces the source project's code generation.
class TextLine {
  final String text;

  /// Y offset from the top of this page's content box (not screen chrome).
  double top;

  /// Line box height used for pagination (fontSize * lineHeight).
  final double height;

  /// When true, Flutter should full-justify to [targetWidth] via letterSpacing.
  final bool justify;

  /// Last soft-wrapped line of a paragraph — never full-justify.
  final bool isLastLine;

  /// True when this line ends a `\n` paragraph.
  final bool isParagraphEnd;

  /// Content-column width the line should fill when [justify] is true.
  final double targetWidth;

  /// Optional paint-time cache. Prefer recomputing from [justify]/[targetWidth].
  double? letterSpacing;

  TextLine(
    this.text, {
    this.top = 0,
    this.height = 0,
    this.justify = false,
    this.isLastLine = false,
    this.isParagraphEnd = false,
    this.targetWidth = 0,
    this.letterSpacing,
  });

  /// Convenience for simple message / fallback lines.
  factory TextLine.simple(
    String text, {
    double top = 0,
    double height = 24,
    double targetWidth = 0,
  }) {
    return TextLine(
      text,
      top: top,
      height: height,
      targetWidth: targetWidth,
      isLastLine: true,
      isParagraphEnd: true,
    );
  }

  factory TextLine.fromJson(Map<String, dynamic> json) {
    return TextLine(
      _s(json['text']),
      top: _d(json['top']),
      height: _d(json['height']),
      justify: _b(json['justify']),
      isLastLine: _b(json['isLastLine']),
      isParagraphEnd: _b(json['isParagraphEnd']),
      targetWidth: _d(json['targetWidth']),
      letterSpacing:
          json['letterSpacing'] == null ? null : _d(json['letterSpacing']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'top': top,
        'height': height,
        'justify': justify,
        'isLastLine': isLastLine,
        'isParagraphEnd': isParagraphEnd,
        'targetWidth': targetWidth,
        'letterSpacing': letterSpacing,
      };

  /// Vertical bottom-justify redistribution (page-level).
  void justifyDy(double offsetDy) {
    top += offsetDy;
  }

  // ---- Backward-compatible aliases (old ABI used dx/dy) ----

  @Deprecated('ABI v3: paint uses paddingLeft, not dx')
  double get dx => 0;

  @Deprecated('ABI v3: use top')
  double get dy => top;

  @Deprecated('ABI v3: use top')
  set dy(double v) => top = v;
}

String _s(Object? v) => v is String ? v : (v == null ? '' : v.toString());

bool _b(Object? v) => v is bool ? v : false;

double _d(Object? v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
