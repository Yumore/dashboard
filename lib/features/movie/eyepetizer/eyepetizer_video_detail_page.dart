import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_data.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page_state.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

/// What "play" does once a stream has been found.
///
/// The default handler pushes the host's [MediaPlaybackPage]; tests inject a
/// recorder instead of building the real player.
typedef EyepetizerPlayHandler =
    Future<void> Function(
      BuildContext context,
      EyepetizerData data,
      List<MediaStreamSource> sources,
    );

/// One 开眼 video plus its "related" strip.
///
/// Port of `module/module_detail/lib/page/video_detail_page.dart`. The source
/// opened its own bundled `VideoWidget` (chewie + `video_player`) on the same
/// page; the port hands the extracted stream URLs to the host's existing player
/// page instead. The source's `Hero` tag, share sheet, favourite button and
/// comment drawer are chrome and are not ported.
class EyepetizerVideoDetailPage extends StatefulWidget {
  const EyepetizerVideoDetailPage({
    required this.data,
    this.api,
    this.onPlay,
    this.onOpenExternal,
    super.key,
  });

  /// The feed item the user tapped; 开眼 has no separate detail endpoint.
  final EyepetizerData data;

  /// Injectable transport for the related strip. When null the page owns one.
  final EyepetizerApi? api;

  /// Overrides the default "open the host player" behaviour.
  final EyepetizerPlayHandler? onPlay;

  /// Overrides `url_launcher` for the no-stream fallback.
  final Future<bool> Function(Uri url)? onOpenExternal;

  @override
  State<EyepetizerVideoDetailPage> createState() =>
      EyepetizerVideoDetailPageState();
}
