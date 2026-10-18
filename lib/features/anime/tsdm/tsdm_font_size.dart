import 'package:dashboard/features/anime/tsdm/tsdm_css_types.dart';
import 'package:flutter/painting.dart';

/// Default text size of forum post content, in logical pixels.
const double tsdmDefaultFontSize = 18;

/// Supported bbcode font sizes.
///
/// Ported from `tsdm_client/lib/utils/html/types.dart`.
enum TsdmFontSize {
  /// `1`: 11px
  size1,

  /// `2`: 14px
  size2,

  /// `3`: 17px
  size3,

  /// `4`: 19px
  size4,

  /// `5`: 25px
  size5,

  /// `6`: 33px
  size6,

  /// `7`: 49px
  size7,

  /// Not supported size.
  notSupport;

  /// Map a raw size attribute to a [TsdmFontSize].
  static TsdmFontSize from(String? size) {
    return switch (size) {
      '1' => TsdmFontSize.size1,
      '2' => TsdmFontSize.size2,
      '3' => TsdmFontSize.size3,
      '4' => TsdmFontSize.size4,
      '5' => TsdmFontSize.size5,
      '6' => TsdmFontSize.size6,
      '7' => TsdmFontSize.size7,
      _ => TsdmFontSize.notSupport,
    };
  }

  /// Font size in logical pixels.
  double get value {
    return switch (this) {
      TsdmFontSize.size1 => 11,
      TsdmFontSize.size2 => 14,
      TsdmFontSize.size3 => 17,
      TsdmFontSize.size4 => 19,
      TsdmFontSize.size5 => 25,
      TsdmFontSize.size6 => 33,
      TsdmFontSize.size7 => 49,
      TsdmFontSize.notSupport => tsdmDefaultFontSize,
    };
  }

  /// Whether the size is supported.
  bool get isValid => this != TsdmFontSize.notSupport;
}

/// A span of inline styles used when the muncher walks the content tree.
class TsdmInlineStyle {
  const TsdmInlineStyle({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.lineThrough = false,
    this.colorValue,
    this.backgroundColorValue,
    this.fontWeight,
    this.fontSize,
    this.href,
  });

  /// Bold style.
  final bool bold;

  /// Italic style.
  final bool italic;

  /// Underline style.
  final bool underline;

  /// Strike through style.
  final bool lineThrough;

  /// Text color as an ARGB integer.
  final int? colorValue;

  /// Background color as an ARGB integer.
  final int? backgroundColorValue;

  /// Font weight parsed from css.
  final FontWeight? fontWeight;

  /// Font size parsed from the `size` attribute.
  final TsdmFontSize? fontSize;

  /// Active link target.
  final String? href;

  /// Font size in logical pixels, null when unset.
  double? get fontSizeValue =>
      fontSize?.isValid ?? false ? fontSize!.value : null;

  /// Return a copy with the given overrides.
  TsdmInlineStyle copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? lineThrough,
    int? colorValue,
    int? backgroundColorValue,
    FontWeight? fontWeight,
    TsdmFontSize? fontSize,
    String? href,
  }) {
    return TsdmInlineStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      lineThrough: lineThrough ?? this.lineThrough,
      colorValue: colorValue ?? this.colorValue,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      fontWeight: fontWeight ?? this.fontWeight,
      fontSize: fontSize ?? this.fontSize,
      href: href ?? this.href,
    );
  }

  /// Merge the css style [css] (parsed from a style attribute) into this style.
  TsdmInlineStyle mergeCss(TsdmCssTypes css) {
    return TsdmInlineStyle(
      bold: bold,
      italic: italic,
      underline: underline,
      lineThrough: lineThrough,
      colorValue: css.color?.toARGB32() ?? colorValue,
      backgroundColorValue:
          css.backgroundColor?.toARGB32() ?? backgroundColorValue,
      fontWeight: css.fontWeight ?? fontWeight,
      fontSize: fontSize,
      href: href,
    );
  }
}
