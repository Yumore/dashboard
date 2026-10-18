import 'dart:ui';

/// Parsed css color/named color helper.
///
/// Replacement for the `dart_bbcode_web_colors` `toColor()` / `WebColors`
/// helpers used by the source project, which are not available in the host
/// pubspec. Supports the color notations that appear in tsdm post html:
/// `#rgb`, `#rrggbb`, `#aarrggbb`, `rgb(r, g, b)`, `rgba(...)` and the css
/// named colors used by the forum themes.
class TsdmCssColor {
  const TsdmCssColor._();

  /// Named css colors appearing in the forum markup.
  static const _named = <String, int>{
    'black': 0xFF000000,
    'silver': 0xFFC0C0C0,
    'gray': 0xFF808080,
    'grey': 0xFF808080,
    'white': 0xFFFFFFFF,
    'maroon': 0xFF800000,
    'red': 0xFFFF0000,
    'purple': 0xFF800080,
    'fuchsia': 0xFFFF00FF,
    'magenta': 0xFFFF00FF,
    'green': 0xFF008000,
    'lime': 0xFF00FF00,
    'olive': 0xFF808000,
    'yellow': 0xFFFFFF00,
    'navy': 0xFF000080,
    'blue': 0xFF0000FF,
    'teal': 0xFF008080,
    'aqua': 0xFF00FFFF,
    'cyan': 0xFF00FFFF,
    'orange': 0xFFFFA500,
    'pink': 0xFFFFC0CB,
    'brown': 0xFFA52A2A,
    'gold': 0xFFFFD700,
    'darkred': 0xFF8B0000,
    'darkblue': 0xFF00008B,
    'darkgreen': 0xFF006400,
    'deeppink': 0xFFFF1493,
    'deepskyblue': 0xFF00BFFF,
    'dodgerblue': 0xFF1E90FF,
    'forestgreen': 0xFF228B22,
    'indigo': 0xFF4B0082,
    'lightblue': 0xFFADD8E6,
    'lightgreen': 0xFF90EE90,
    'lightpink': 0xFFFFB6C1,
    'lightyellow': 0xFFFFFFE0,
    'mediumblue': 0xFF0000CD,
    'mediumpurple': 0xFF9370DB,
    'orangered': 0xFFFF4500,
    'royalblue': 0xFF4169E1,
    'seagreen': 0xFF2E8B57,
    'springgreen': 0xFF00FF7F,
    'tomato': 0xFFFF6347,
    'violet': 0xFFEE82EE,
    'yellowgreen': 0xFF9ACD32,
  };

  static final _hexRe = RegExp(
    r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  );
  static final _rgbRe = RegExp(
    r'^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*[\d.]+\s*)?\)$',
  );

  /// Parse [value] into an ARGB color value, null when not a color.
  static int? parse(String? value) {
    if (value == null) {
      return null;
    }
    final v = value.trim().toLowerCase();
    if (v.isEmpty) {
      return null;
    }

    final named = _named[v];
    if (named != null) {
      return named;
    }

    final rgb = _rgbRe.firstMatch(v);
    if (rgb != null) {
      final r = int.parse(rgb.group(1)!);
      final g = int.parse(rgb.group(2)!);
      final b = int.parse(rgb.group(3)!);
      if (r > 255 || g > 255 || b > 255) {
        return null;
      }
      return 0xFF000000 | (r << 16) | (g << 8) | b;
    }

    final hex = _hexRe.firstMatch(v);
    if (hex == null) {
      return null;
    }
    final digits = hex.group(1)!;
    return switch (digits.length) {
      3 =>
        0xFF000000 |
            (int.parse(digits[0] * 2, radix: 16) << 16) |
            (int.parse(digits[1] * 2, radix: 16) << 8) |
            int.parse(digits[2] * 2, radix: 16),
      6 => 0xFF000000 | int.parse(digits, radix: 16),
      _ => int.parse(digits, radix: 16),
    };
  }

  /// Parse [value] into a [Color], null when not a color.
  static Color? toColor(String? value) {
    final parsed = parse(value);
    return parsed == null ? null : Color(parsed);
  }

  /// Whether [value] is a parsable color.
  static bool isValid(String? value) => parse(value) != null;
}
