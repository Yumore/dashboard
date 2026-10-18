import 'package:flutter/material.dart';

/// Accent colour owned by each content module.
///
/// The hub and the module page both read the same value so a module keeps one
/// identity colour everywhere.
abstract final class ContentAccents {
  static const Color reading = Colors.teal;
  static const Color novel = Colors.indigo;
  static const Color anime = Colors.deepPurple;
  static const Color comic = Colors.pink;
  static const Color movie = Colors.orange;
  static const Color chat = Colors.green;
  static const Color live = Colors.red;
  static const Color crawler = Colors.blueGrey;
}
