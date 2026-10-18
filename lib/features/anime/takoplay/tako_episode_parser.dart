import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:html/parser.dart' as html;

/// Parser for the `ajax/load-list-episode` episode list.
class TakoEpisodeParser {
  const TakoEpisodeParser._();

  /// Returns the episodes in the order the endpoint publishes them (newest
  /// first); callers reverse for playback order.
  static List<TakoEpisode> parse(String source, {required Uri base}) {
    final document = html.parse(source);
    final items = document
        .getElementById('episode_related')
        ?.querySelectorAll('li');
    if (items == null) return const [];

    final episodes = <TakoEpisode>[];
    for (final item in items) {
      final anchor = item.querySelector('a');
      if (anchor == null) continue;
      final href = anchor.attributes.values.isEmpty
          ? ''
          : anchor.attributes.values.first;
      final label =
          anchor.querySelector('.name')?.text.trim() ?? anchor.text.trim();
      episodes.add(
        TakoEpisode(
          number: label.split('EP ').last.trim(),
          link: base.resolve(href),
        ),
      );
    }
    return episodes;
  }
}
