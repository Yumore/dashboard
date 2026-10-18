import 'package:html/parser.dart' as html;

/// Parser for the `play-video` iframe of an episode page.
class TakoEmbedParser {
  const TakoEmbedParser._();

  /// Absolute URL of the gogoplay embed player, or null when the page has no
  /// playable iframe (e.g. the episode was taken down).
  static Uri? iframe(String source, {required Uri base}) {
    final document = html.parse(source);
    final container = document.getElementsByClassName('play-video');
    if (container.isEmpty) return null;
    final iframe = container.first.querySelector('iframe');
    if (iframe == null) return null;
    final href = iframe.attributes.values.isEmpty
        ? ''
        : iframe.attributes.values.first;
    return href.isEmpty ? null : base.resolve(href);
  }
}
