/// A Tako-Play (gogoanime.wiki) anime card: a search hit, a catalogue row or a
/// recently updated episode.
class TakoAnime {
  const TakoAnime({
    required this.title,
    required this.url,
    this.id = '',
    this.image,
    this.releasedDate = '',
    this.currentEpisode = '',
  });

  /// Stable identifier: the source UUIDs search hits, the title for recently
  /// updated rows (source behaviour).
  final String id;

  final String title;
  final Uri url;
  final Uri? image;

  /// `Released:` value from a catalogue card, e.g. `2021`.
  final String releasedDate;

  /// Latest episode label from a recently updated row, e.g. `Episode 12`.
  final String currentEpisode;

  @override
  String toString() => 'TakoAnime($title, $url)';
}
