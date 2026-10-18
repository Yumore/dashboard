/// One episode row of a Tako-Play (gogoanime.wiki) episode list.
class TakoEpisode {
  const TakoEpisode({required this.number, required this.link});

  /// Episode number as published, e.g. `12` from `EP 12`.
  final String number;

  /// Absolute episode page URL (`/anime-name-episode-12`).
  final Uri link;

  @override
  String toString() => 'TakoEpisode($number, $link)';
}
