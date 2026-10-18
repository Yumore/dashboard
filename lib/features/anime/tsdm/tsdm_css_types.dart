import 'package:flutter/material.dart';

/// Css decoration parsed from a thread entry `style` attribute.
///
/// Ported from `tsdm_client/lib/shared/models/css_types.dart`.
class TsdmCssTypes {
  const TsdmCssTypes({
    required this.fontWeight,
    required this.color,
    required this.backgroundColor,
  });

  /// Font weight converted from css.
  final FontWeight? fontWeight;

  /// Font color converted from css.
  final Color? color;

  /// Text background color converted from css.
  final Color? backgroundColor;
}
