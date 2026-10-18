import 'package:html/parser.dart' as html_parser;

/// Converts an html fragment into the plain text of its content.
///
/// The source client renders post bodies through its bbcode widget tree
/// (`tsdm_client/lib/utils/html/html_muncher.dart`); this helper keeps the text
/// of the same fragment without any Flutter widget dependency, so the parsed
/// [TsdmPost] fields stay testable and authoritative.
extension TsdmPlainTextExtension on String {
  /// Plain text of this html fragment.
  ///
  /// `<br>` and block level tags are turned into line breaks, all other tags
  /// are dropped and the remaining text is unescaped.
  String extractPlainText() {
    final fragment = html_parser.parseFragment(
      replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n'),
    );
    return (fragment.text ?? '').trim();
  }
}
