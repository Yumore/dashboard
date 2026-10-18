import 'package:dashboard/features/anime/takoplay/tako_stream_source.dart';

/// Everything needed to hand one episode to the host player.
class TakoPlayback {
  const TakoPlayback({
    required this.title,
    required this.page,
    required this.sources,
  });

  final String title;

  /// Episode page URL, used as the player's history id.
  final Uri page;

  final List<TakoStreamSource> sources;
}
