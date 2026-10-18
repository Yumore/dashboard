import 'package:dashboard/features/anime/anime_playback.dart';
import 'package:dashboard/features/anime/animeone/animeone_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:dashboard/features/media/media_stream_source.dart';

/// 把 anime1.me 的剧集链接解析成宿主播放器需要的 [AnimePlayback]。
///
/// 流程与源应用一致：抓单集页 → 选一个可播放的 hentry → 用令牌换真实地址。
class AnimeOnePlaybackResolver {
  AnimeOnePlaybackResolver(this.client);

  final AnimeOneSiteClient client;

  /// 解析剧集；页面没有可用视频源时抛出 [FormatException]。
  Future<AnimePlayback> resolve(
    String episodeLink, {
    String? title,
    Uri? previous,
  }) async {
    final result = await client.getPage(link: episodeLink, page: 1);
    AnimeOneEntry? entry;
    for (final item in result.entries) {
      final video = item.video;
      if (video == null || video.isEmpty || video.isYoutube) continue;
      entry = item;
      break;
    }
    if (entry == null) {
      throw const FormatException('该剧集暂无可用播放地址');
    }

    final source = await client.getVideoSource(entry.video);
    final url = source.url;
    if (!source.available || url == null) {
      throw const FormatException('视频源解析失败');
    }

    // 播放 CDN 校验 e/p/h cookie，同时带上站点 cookie 与 referer。
    final cookie = source.cookie;
    final headers = <String, String>{
      'referer': AnimeOneUrl.domain,
      'user-agent': AnimeOneSiteClient.userAgent,
      if (cookie != null && cookie.isNotEmpty)
        'cookie': '${client.cookie}; $cookie',
    };
    return AnimePlayback(
      title: entry.formattedName()?.trim() ?? title ?? '动漫播放',
      page: Uri.parse(entry.link ?? episodeLink),
      sources: [
        MediaStreamSource(label: '默认', url: Uri.parse(url), headers: headers),
      ],
      previous: previous,
      next: entry.hasNextEpisode() ? Uri.parse(entry.nextEpisode!) : null,
    );
  }
}
