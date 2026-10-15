import 'package:dashboard/features/media/media_stream_source.dart';

class AnimePlayback {
  const AnimePlayback({
    required this.title,
    required this.page,
    required this.sources,
    this.previous,
    this.next,
  });

  final String title;
  final Uri page;
  final List<MediaStreamSource> sources;
  final Uri? previous;
  final Uri? next;
}
