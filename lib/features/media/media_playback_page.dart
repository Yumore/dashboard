import 'package:dashboard/features/media/media_playback_page_state_stub.dart'
    if (dart.library.io) 'package:dashboard/features/media/media_playback_page_state.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class MediaPlaybackPage extends StatefulWidget {
  const MediaPlaybackPage({
    required this.title,
    required this.sources,
    this.historyId,
    this.previousPage,
    this.nextPage,
    super.key,
  }) : assert(sources.length > 0);

  final String title;
  final List<MediaStreamSource> sources;
  final String? historyId;
  final WidgetBuilder? previousPage;
  final WidgetBuilder? nextPage;

  @override
  State<MediaPlaybackPage> createState() => MediaPlaybackPageState();
}
