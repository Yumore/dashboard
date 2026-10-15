import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

/// Ports book's HTML chapter cleanup and Legado replace-regex behavior.
class ChapterTextCleaner {
  const ChapterTextCleaner();

  String clean(String source, {String replaceRule = ''}) {
    final document = html.parse(source);
    for (final node in document.querySelectorAll('script, style, button')) {
      node.remove();
    }
    for (final node in document.querySelectorAll('br')) {
      node.replaceWith(dom.Text('\n'));
    }
    for (final node in document.querySelectorAll(
      'p, div, h1, h2, h3, h4, h5, h6',
    )) {
      node.nodes.add(dom.Text('\n'));
    }
    var text = document.body?.text ?? document.documentElement?.text ?? '';
    for (final rule in replaceRule.split('&&')) {
      final parts = rule.split('##');
      if (parts.first.trim().isEmpty) continue;
      try {
        text = text.replaceAll(
          RegExp(parts.first, multiLine: true, dotAll: true),
          parts.length > 1 ? parts[1] : '',
        );
      } on FormatException {
        // A malformed user rule does not discard an otherwise readable chapter.
      }
    }
    return text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.replaceAll(RegExp(r'[ \t\u00a0]+'), ' ').trim())
        .where(
          (line) => line.isNotEmpty && !RegExp(r'^\d{1,4}$').hasMatch(line),
        )
        .join('\n');
  }
}
