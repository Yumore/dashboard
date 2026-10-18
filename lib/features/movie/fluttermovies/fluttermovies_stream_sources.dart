import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_episode.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source.dart';

/// 分集 → host 的 media_kit 播放源；只保留 http/https 地址。
class FlutterMoviesStreamSources {
  const FlutterMoviesStreamSources._();

  static List<MediaStreamSource> of(FlutterMoviesPlaySource source) {
    final result = <MediaStreamSource>[];
    for (final episode in source.episodes) {
      final uri = episode.uri;
      if (uri == null) continue;
      result.add(MediaStreamSource(label: episode.label, url: uri));
    }
    return result;
  }

  /// 单集列表（用于「上一集 / 下一集」那样的单集播放页）。
  static List<MediaStreamSource> single(FlutterMoviesPlayEpisode episode) {
    final uri = episode.uri;
    if (uri == null) return const <MediaStreamSource>[];
    return <MediaStreamSource>[
      MediaStreamSource(label: episode.label, url: uri),
    ];
  }
}
