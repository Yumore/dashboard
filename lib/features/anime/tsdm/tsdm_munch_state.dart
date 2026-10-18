import 'dart:ui';

import 'package:flutter/painting.dart';

/// Mutable inline style state of post content parsing.
///
/// The source project tracked this state in `MunchState` of
/// `tsdm_client/lib/utils/html/html_muncher.dart`. The port keeps the same
/// fields so the same style nesting rules apply.
class TsdmMunchState {
  /// Bold style.
  bool bold = false;

  /// Italic style.
  bool italic = false;

  /// Underlined style.
  bool underline = false;

  /// Struck through style.
  bool lineThrough = false;

  /// Current text color.
  Color? color;

  /// Current background color.
  Color? backgroundColor;

  /// Current font weight.
  FontWeight? fontWeight;

  /// Current font size.
  double? fontSize;

  /// Current tap url, set while parsing the content of an `<a>` tag.
  String? tapUrl;

  /// Current text alignment.
  TextAlign? textAlign;

  /// Whether a `<br>` node is allowed at the current position.
  bool headingBrNodePassed = false;

  /// Whether the parser is inside a `<div>` node.
  bool inDiv = false;

  /// Whether content is currently inside a spin lock (whitespace collapsing).
  bool wrapInWord = false;

  /// List stack, used to produce list item leading markers.
  final List<TsdmListType> listStack = [];

  /// Save the style state, used when parsing quoted and spoiler content.
  TsdmMunchSnapshot save() => TsdmMunchSnapshot._of(this);

  /// Restore a previously saved style state.
  void restore(TsdmMunchSnapshot snapshot) {
    bold = snapshot.bold;
    italic = snapshot.italic;
    underline = snapshot.underline;
    lineThrough = snapshot.lineThrough;
    color = snapshot.color;
    backgroundColor = snapshot.backgroundColor;
    fontWeight = snapshot.fontWeight;
    fontSize = snapshot.fontSize;
    tapUrl = snapshot.tapUrl;
    textAlign = snapshot.textAlign;
    headingBrNodePassed = snapshot.headingBrNodePassed;
    inDiv = snapshot.inDiv;
    wrapInWord = snapshot.wrapInWord;
    listStack
      ..clear()
      ..addAll(snapshot.listStack);
  }
}

/// Immutable snapshot of [TsdmMunchState].
class TsdmMunchSnapshot {
  TsdmMunchSnapshot._of(TsdmMunchState state)
    : bold = state.bold,
      italic = state.italic,
      underline = state.underline,
      lineThrough = state.lineThrough,
      color = state.color,
      backgroundColor = state.backgroundColor,
      fontWeight = state.fontWeight,
      fontSize = state.fontSize,
      tapUrl = state.tapUrl,
      textAlign = state.textAlign,
      headingBrNodePassed = state.headingBrNodePassed,
      inDiv = state.inDiv,
      wrapInWord = state.wrapInWord,
      listStack = List<TsdmListType>.of(state.listStack);

  /// Captured bold style.
  final bool bold;

  /// Captured italic style.
  final bool italic;

  /// Captured underline style.
  final bool underline;

  /// Captured strike through style.
  final bool lineThrough;

  /// Captured text color.
  final Color? color;

  /// Captured background color.
  final Color? backgroundColor;

  /// Captured font weight.
  final FontWeight? fontWeight;

  /// Captured font size.
  final double? fontSize;

  /// Captured tap url.
  final String? tapUrl;

  /// Captured text alignment.
  final TextAlign? textAlign;

  /// Captured `<br>` allowance.
  final bool headingBrNodePassed;

  /// Captured div nesting flag.
  final bool inDiv;

  /// Captured wrap in word flag.
  final bool wrapInWord;

  /// Captured list stack.
  final List<TsdmListType> listStack;
}

/// Type of the currently open html list.
sealed class TsdmListType {
  const TsdmListType();
}

/// An unordered list.
final class TsdmUnorderedList extends TsdmListType {
  const TsdmUnorderedList();
}

/// An ordered list carrying the next item number.
final class TsdmOrderedList extends TsdmListType {
  const TsdmOrderedList(this.number);

  /// Next item number.
  final int number;
}
