import 'package:dashboard/features/anime/tsdm/tsdm_css_types.dart';
import 'package:flutter/painting.dart';

/// Minimal css style parsing used by the thread list and the post muncher.
///
/// The source project used `parseCssString` from `tsdm_client/lib/utils/html/css_parser.dart`
/// together with the `dart_bbcode_web_colors` package for color names. That
/// package is not available in the host application, so the small replacement
/// below keeps the same behavior: the same `font-weight` values and the same
/// css color formats the forum writes into `style` attributes.
/// Parse a css declaration string such as `font-weight: bold;color: #ff0000;`.
///
/// Ported from `parseCssString` of `tsdm_client/lib/utils/html/css_parser.dart`:
/// the parts are split on `;`, each part is split at its first `:` and an empty
/// value is ignored. Unknown properties are ignored, so an empty style string
/// still yields an empty [TsdmCssTypes].
TsdmCssTypes parseTsdmCssString(String css) {
  Color? color;
  Color? backgroundColor;
  FontWeight? fontWeight;

  for (final part in css.split(';')) {
    final separatorIndex = part.indexOf(':');
    if (separatorIndex < 0 || separatorIndex == part.length - 1) {
      continue;
    }
    final name = part.substring(0, separatorIndex).trim();
    final value = part.substring(separatorIndex + 1).trim();

    switch (name) {
      case 'font-weight':
        fontWeight = parseTsdmFontWeight(value) ?? _parseFontWeight(value);
      case 'color':
        color = parseTsdmColor(value);
      case 'background-color':
        backgroundColor = parseTsdmColor(value);
      default:
        continue;
    }
  }

  return TsdmCssTypes(
    color: color,
    fontWeight: fontWeight,
    backgroundColor: backgroundColor,
  );
}

/// Parse a css `font-weight` value into a [FontWeight], null when unknown.
FontWeight? parseTsdmFontWeight(String data) {
  final weight = int.tryParse(data.trim());
  if (weight == null || weight < 100 || weight > 900 || weight % 100 != 0) {
    return null;
  }
  return FontWeight.values[(weight ~/ 100) - 1];
}

FontWeight? _parseFontWeight(String data) {
  return switch (data) {
    '100' => FontWeight.w100,
    '200' => FontWeight.w200,
    '300' => FontWeight.w300,
    '400' => FontWeight.w400,
    '500' => FontWeight.w500,
    '600' => FontWeight.w600,
    '700' => FontWeight.w700,
    '800' => FontWeight.w800,
    '900' => FontWeight.w900,
    'bold' => FontWeight.bold,
    _ => null,
  };
}

final _hex3Re = RegExp(
  r'^#(?<r>[0-9a-fA-F])(?<g>[0-9a-fA-F])(?<b>[0-9a-fA-F])$',
);
final _hex6Re = RegExp(
  r'^#(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})$',
);
final _hex8Re = RegExp(
  r'^#(?<a>[0-9a-fA-F]{2})(?<r>[0-9a-fA-F]{2})(?<g>[0-9a-fA-F]{2})(?<b>[0-9a-fA-F]{2})$',
);
final _rgbRe = RegExp(
  r'^rgba?\((?<r>\d+)\s*,\s*(?<g>\d+)\s*,\s*(?<b>\d+)(?:\s*,\s*(?<a>[\d.]+))?\)$',
);

/// Parse a css color into a [Color], null when the value is unknown.
Color? parseTsdmColor(String value) {
  final argb = parseTsdmColorValue(value);
  return argb == null ? null : Color(argb);
}

/// Parse a css color into an ARGB integer, null when the value is unknown.
int? parseTsdmColorValue(String value) {
  final data = value.trim().toLowerCase();
  if (data.isEmpty) {
    return null;
  }

  final color = _namedColors[data];
  if (color != null) {
    return color;
  }

  final rgb = _rgbRe.firstMatch(data);
  if (rgb != null) {
    final r = int.tryParse(rgb.namedGroup('r') ?? '');
    final g = int.tryParse(rgb.namedGroup('g') ?? '');
    final b = int.tryParse(rgb.namedGroup('b') ?? '');
    if (r == null || g == null || b == null) {
      return null;
    }
    final a = double.tryParse(rgb.namedGroup('a') ?? '1') ?? 1;
    return _argb((a * 255).round(), r, g, b);
  }

  final hex6 = _hex6Re.firstMatch(data);
  if (hex6 != null) {
    return _argb(
      0xff,
      int.parse(hex6.namedGroup('r')!, radix: 16),
      int.parse(hex6.namedGroup('g')!, radix: 16),
      int.parse(hex6.namedGroup('b')!, radix: 16),
    );
  }

  final hex3 = _hex3Re.firstMatch(data);
  if (hex3 != null) {
    final r = int.parse(
      '${hex3.namedGroup('r')}${hex3.namedGroup('r')}',
      radix: 16,
    );
    final g = int.parse(
      '${hex3.namedGroup('g')}${hex3.namedGroup('g')}',
      radix: 16,
    );
    final b = int.parse(
      '${hex3.namedGroup('b')}${hex3.namedGroup('b')}',
      radix: 16,
    );
    return _argb(0xff, r, g, b);
  }

  final hex8 = _hex8Re.firstMatch(data);
  if (hex8 != null) {
    return _argb(
      int.parse(hex8.namedGroup('a')!, radix: 16),
      int.parse(hex8.namedGroup('r')!, radix: 16),
      int.parse(hex8.namedGroup('g')!, radix: 16),
      int.parse(hex8.namedGroup('b')!, radix: 16),
    );
  }

  return null;
}

int _argb(int a, int r, int g, int b) {
  return ((a & 0xff) << 24) |
      ((r & 0xff) << 16) |
      ((g & 0xff) << 8) |
      (b & 0xff);
}

/// The subset of css named colors the forum actually emits.
const Map<String, int> _namedColors = {
  'black': 0xff000000,
  'silver': 0xffc0c0c0,
  'gray': 0xff808080,
  'grey': 0xff808080,
  'white': 0xffffffff,
  'maroon': 0xff800000,
  'red': 0xffff0000,
  'purple': 0xff800080,
  'fuchsia': 0xffff00ff,
  'magenta': 0xffff00ff,
  'green': 0xff008000,
  'lime': 0xff00ff00,
  'olive': 0xff808000,
  'yellow': 0xffffff00,
  'navy': 0xff000080,
  'blue': 0xff0000ff,
  'teal': 0xff008080,
  'aqua': 0xff00ffff,
  'cyan': 0xff00ffff,
  'orange': 0xffffa500,
  'brown': 0xffa52a2a,
  'pink': 0xffffc0cb,
  'gold': 0xffffd700,
  'indigo': 0xff4b0082,
  'violet': 0xffee82ee,
  'darkred': 0xff8b0000,
  'darkgreen': 0xff006400,
  'darkblue': 0xff00008b,
  'darkorange': 0xffff8c00,
  'darkgray': 0xffa9a9a9,
  'darkgrey': 0xffa9a9a9,
  'lightgray': 0xffd3d3d3,
  'lightgrey': 0xffd3d3d3,
  'lightblue': 0xffadd8e6,
  'lightgreen': 0xff90ee90,
  'lightyellow': 0xffffffe0,
  'lightpink': 0xffffb6c1,
  'skyblue': 0xff87ceeb,
  'deepskyblue': 0xff00bfff,
  'dodgerblue': 0xff1e90ff,
  'steelblue': 0xff4682b4,
  'royalblue': 0xff4169e1,
  'seagreen': 0xff2e8b57,
  'forestgreen': 0xff228b22,
  'springgreen': 0xff00ff7f,
  'limegreen': 0xff32cd32,
  'olivedrab': 0xff6b8e23,
  'tomato': 0xffff6347,
  'orangered': 0xffff4500,
  'crimson': 0xffdc143c,
  'firebrick': 0xffb22222,
  'salmon': 0xfffa8072,
  'coral': 0xffff7f50,
  'khaki': 0xfff0e68c,
  'plum': 0xffdda0dd,
  'orchid': 0xffda70d6,
  'turquoise': 0xff40e0d0,
  'sienna': 0xffa0522d,
  'chocolate': 0xffd2691e,
  'peru': 0xffcd853f,
  'tan': 0xffd2b48c,
  'beige': 0xfff5f5dc,
  'ivory': 0xfffffff0,
  'snow': 0xfffffafa,
  'azure': 0xfff0ffff,
  'lavender': 0xffe6e6fa,
  'wheat': 0xfff5deb3,
  'transparent': 0x00000000,
};
