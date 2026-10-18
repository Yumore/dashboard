import 'package:dashboard/features/movie/eyepetizer/eyepetizer_data.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_image.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_play_url.dart';
import 'package:dashboard/features/media/media_stream_source.dart';

/// Everything the host player needs for one 开眼 video.
///
/// The source had no such type: `video_detail_page.dart` passed `data.playUrl`
/// straight into its bundled `VideoWidget` and dropped `data.playInfo`
/// entirely. The port keeps the same first source so behaviour is unchanged,
/// then exposes the rest of `playInfo` as selectable qualities.
class EyepetizerPlayback {
  const EyepetizerPlayback({
    this.sources = const <MediaStreamSource>[],
    this.externalUrl,
  });

  /// Player sources, best-first. Empty when the payload has no stream URL.
  final List<MediaStreamSource> sources;

  /// `webUrl.raw` — the Kaiyan share page, opened externally when there is no
  /// playable stream.
  final Uri? externalUrl;

  bool get hasStream => sources.isNotEmpty;

  static EyepetizerPlayback from(EyepetizerData data) {
    final sources = <MediaStreamSource>[];
    final seen = <String>{};

    void add(String label, Object? rawUrl) {
      final url = EyepetizerImage.resolve(rawUrl);
      if (url == null) return;
      if (!seen.add(url)) return;
      sources.add(MediaStreamSource(label: label, url: Uri.parse(url)));
    }

    add('默认', data.playUrl);
    for (final info in data.playInfo) {
      final family = info.name.isNotEmpty ? info.name : info.type;
      if (info.urlList.isEmpty) {
        add(family.isEmpty ? '播放地址' : family, info.url);
        continue;
      }
      for (final entry in info.urlList) {
        add(_labelFor(family, entry), entry.url);
      }
    }

    final external = EyepetizerImage.resolve(data.webUrl?.raw);
    return EyepetizerPlayback(
      sources: sources,
      externalUrl: external == null ? null : Uri.parse(external),
    );
  }

  static String _labelFor(String family, EyepetizerPlayUrl entry) {
    final quality = entry.name.isNotEmpty
        ? entry.name
        : (entry.size > 0 ? '${entry.size}p' : '');
    final label = <String>[
      if (family.isNotEmpty) family,
      if (quality.isNotEmpty) quality,
    ].join(' · ');
    return label.isEmpty ? '播放地址' : label;
  }
}
