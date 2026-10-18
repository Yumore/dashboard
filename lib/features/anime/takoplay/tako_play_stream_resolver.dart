import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_playback.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_extractor.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_source.dart';

/// Turns an episode page into playable sources:
/// episode page -> `play-video` iframe -> AES extraction -> sources.
///
/// When the AES pipeline fails (taken down embed, changed markup) the client's
/// `download` mirror table is used instead, which is the fallback the source's
/// `video_list_screen` offered as a manual quality picker.
///
/// The extractor runs over the *same* transport as the client, so an injected
/// test client covers the whole pipeline.
class TakoPlayStreamResolver {
  factory TakoPlayStreamResolver({
    TakoPlayClient? client,
    TakoStreamExtractor? extractor,
  }) {
    final playClient = client ?? TakoPlayClient();
    return TakoPlayStreamResolver._(
      client: playClient,
      ownsClient: client == null,
      extractor:
          extractor ?? TakoStreamExtractor(client: playClient.httpClient),
      ownsExtractor: extractor == null,
    );
  }

  const TakoPlayStreamResolver._({
    required TakoPlayClient client,
    required bool ownsClient,
    required TakoStreamExtractor extractor,
    required bool ownsExtractor,
  }) : _client = client,
       _ownsClient = ownsClient,
       _extractor = extractor,
       _ownsExtractor = ownsExtractor;

  final TakoPlayClient _client;
  final bool _ownsClient;
  final TakoStreamExtractor _extractor;
  final bool _ownsExtractor;

  Future<TakoPlayback> resolve(TakoEpisode episode, {String title = ''}) async {
    final embed = await _client.embedUrl(episode.link);
    if (embed == null) {
      throw const FormatException('该集没有可用的播放地址');
    }
    final label = title.isEmpty ? '第${episode.number}集' : title;
    try {
      return TakoPlayback(
        title: label,
        page: episode.link,
        sources: await _extractor.extract(embed.toString()),
      );
    } catch (error) {
      final mirrors = await _client.mirrors(embed);
      if (mirrors.isEmpty) rethrow;
      return TakoPlayback(
        title: label,
        page: episode.link,
        sources: mirrors.entries
            .map(
              (mirror) => TakoStreamSource(
                label: mirror.key,
                url: mirror.value,
                type: 'mp4',
              ),
            )
            .toList(),
      );
    }
  }

  /// Closes only the clients this resolver created itself.
  void dispose() {
    if (_ownsExtractor) _extractor.dispose();
    if (_ownsClient) _client.dispose();
  }
}
