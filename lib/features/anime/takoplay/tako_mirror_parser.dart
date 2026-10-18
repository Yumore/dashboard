import 'package:html/parser.dart' as html;

/// Parser for the gogoanime `download` mirror table, ported from the source's
/// `fetchCdnStreamLink`: every `.dowload` anchor is labelled by the first
/// `[0-9]+P` token of its text (e.g. `1080P`), and the first link wins.
class TakoMirrorParser {
  const TakoMirrorParser._();

  static final RegExp resolutionPattern = RegExp(r'[0-9]+(P)');

  static Map<String, Uri> parse(String source, {required Uri base}) {
    final document = html.parse(source);
    final container = document.getElementsByClassName('mirror_link');
    if (container.isEmpty) return const {};

    final mirrors = <String, Uri>{};
    for (final row in container.first.getElementsByClassName('dowload')) {
      final anchor = row.querySelector('a');
      if (anchor == null) continue;
      final match = resolutionPattern.firstMatch(anchor.text);
      if (match == null) continue;
      final href = anchor.attributes.values.isEmpty
          ? ''
          : anchor.attributes.values.first;
      if (href.isEmpty) continue;
      mirrors.putIfAbsent(match.group(0)!, () => base.resolve(href));
    }
    return mirrors;
  }
}
