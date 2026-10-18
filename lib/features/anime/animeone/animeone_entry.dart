import 'package:dashboard/features/anime/animeone/animeone_basic.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:dashboard/features/anime/animeone/animeone_video.dart';
import 'package:html/dom.dart';

/// 分类页里的一个剧集条目（div.hentry）。
class AnimeOneEntry extends AnimeOneBasic {
  AnimeOneEntry({
    super.name,
    super.link,
    this.postDate,
    this.allEpisodes,
    this.nextEpisode,
    this.video,
  });

  /// 解析 hentry 区块；站点结构变动时保留已解析到的字段而不抛异常。
  factory AnimeOneEntry.fromElement(Element element) {
    final entry = AnimeOneEntry();
    final titles = element.getElementsByClassName('entry-title');
    if (titles.isEmpty) return entry;
    final title = titles.first;
    final node = title.nodes.isEmpty ? null : title.nodes.first;
    entry.name = node?.text;
    if (node is Element) {
      entry.link = AnimeOneUrl.absolute(node.attributes['href']);
    } else {
      final anchors = title.getElementsByTagName('a');
      if (anchors.isNotEmpty) {
        entry.link = AnimeOneUrl.absolute(anchors.first.attributes['href']);
      }
    }

    final dates = element.getElementsByClassName('entry-date');
    if (dates.isNotEmpty) entry.postDate = dates.first.text;

    // 视频源有四种写法：iframe、JS 懒加载按钮、密码保护、YouTube 预告、
    // video[data-apireq] 编码令牌。
    final frames = element.getElementsByTagName('iframe');
    final loadButtons = element.getElementsByClassName('loadvideo');
    final passwords = element.getElementsByClassName('acpwd-container');
    final players = element.getElementsByClassName('youtubePlayer');
    final videos = element.getElementsByTagName('video');
    if (frames.isNotEmpty) {
      entry.video = AnimeOneVideo(frames.first.attributes['src']);
    } else if (loadButtons.isNotEmpty) {
      entry.video = AnimeOneVideo(loadButtons.first.attributes['data-src']);
    } else if (passwords.isNotEmpty) {
      // 部分地区因版权限制需要密码，视频源保持为空。
    } else if (players.isNotEmpty) {
      entry.video = AnimeOneVideo(
        'https://youtube.com/watch?v='
        '${players.first.attributes['data-vid'] ?? ''}',
      );
    } else if (videos.isNotEmpty) {
      entry.video = AnimeOneVideo(videos.first.attributes['data-apireq']);
    }

    for (final anchor in element.getElementsByTagName('a')) {
      final href = anchor.attributes['href'];
      if (href == null) continue;
      final text = anchor.text;
      if (text.contains('全集')) {
        entry.allEpisodes = AnimeOneUrl.absolute(href);
      } else if (text.contains('下一集')) {
        entry.nextEpisode = AnimeOneUrl.absolute(href);
      }
    }
    return entry;
  }

  String? postDate;
  String? allEpisodes;
  String? nextEpisode;
  AnimeOneVideo? video;

  /// 是否存在有效的下一集链接。
  bool hasNextEpisode() {
    final next = nextEpisode;
    if (next == null || next.isEmpty) return false;
    return !next.endsWith('/?p=');
  }

  /// 站点用空视频源表示需要密码。
  bool needPassword() => video == null || video!.isEmpty;

  /// 发布时间 + 距今多久，例如 "2024-04-01 | 3天前"。
  String enhancedDate(DateTime now) {
    final value = postDate;
    if (value == null || value.isEmpty) return '未知时间';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final days = parsed.difference(now).inDays.abs();
    final String relative;
    if (days == 0) {
      relative = '今天';
    } else if (days == 1) {
      relative = '昨天';
    } else if (days < 7) {
      relative = '$days天前';
    } else if (days < 28) {
      relative = '${(days / 7).round()}周前';
    } else if (days < 365) {
      relative = '${(days / 30).toStringAsFixed(1)}个月前';
    } else {
      relative = '${(days / 365).toStringAsFixed(1)}年前';
    }
    return '$value | $relative';
  }
}
