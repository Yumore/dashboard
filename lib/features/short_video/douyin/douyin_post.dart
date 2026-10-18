import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// `tiktok.com/share/item/list` 返回的一条作品。
///
/// 源工程 `Tiktok.dart` 为它写了 8 个嵌套类；宿主列表只需要拍平后的展示字段，
/// 因此这里把 `itemInfos/authorInfos/musicInfos` 三个子对象压成一个值对象，
/// 原始字段名写在 [DouyinPost.fromJson] 里。
class DouyinPost {
  const DouyinPost({
    this.id = '',
    this.desc = '',
    this.createTime = '',
    this.authorUniqueId = '',
    this.authorNickname = '',
    this.authorAvatar = '',
    this.musicTitle = '',
    this.musicAuthor = '',
    this.musicCover = '',
    this.playUrls = const <String>[],
    this.diggCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.playCount = 0,
    this.duration = 0,
  });

  factory DouyinPost.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    final item = DouyinJson.asMap(map['itemInfos']);
    final author = DouyinJson.asMap(map['authorInfos']);
    final music = DouyinJson.asMap(map['musicInfos']);
    final video = DouyinJson.asMap(item['video']);
    final meta = DouyinJson.asMap(video['videoMeta']);
    return DouyinPost(
      id: DouyinJson.asString(item['id']),
      desc: DouyinJson.asString(item['text']),
      createTime: DouyinJson.asString(item['createTime']),
      authorUniqueId: DouyinJson.asString(author['uniqueId']),
      authorNickname: DouyinJson.asString(author['nickName']),
      authorAvatar: DouyinJson.firstString(author['covers']),
      musicTitle: DouyinJson.asString(music['musicName']),
      musicAuthor: DouyinJson.asString(music['authorName']),
      musicCover: DouyinJson.firstString(music['covers']),
      playUrls: DouyinJson.stringList(video['urls']),
      diggCount: DouyinJson.asInt(item['diggCount']),
      commentCount: DouyinJson.asInt(item['commentCount']),
      shareCount: DouyinJson.asInt(item['shareCount']),
      playCount: DouyinJson.asInt(item['playCount']),
      duration: DouyinJson.asInt(meta['duration']),
    );
  }

  final String id;
  final String desc;
  final String createTime;
  final String authorUniqueId;
  final String authorNickname;
  final String authorAvatar;
  final String musicTitle;
  final String musicAuthor;
  final String musicCover;
  final List<String> playUrls;
  final int diggCount;
  final int commentCount;
  final int shareCount;
  final int playCount;
  final int duration;

  String get displayDesc => desc.trim().isEmpty ? '无描述' : desc.trim();

  String get authorHandle {
    if (authorUniqueId.isNotEmpty) {
      return '@$authorUniqueId';
    }
    if (authorNickname.isNotEmpty) {
      return '@$authorNickname';
    }
    return '@未知用户';
  }

  String get musicLabel {
    final title = musicTitle.trim().isEmpty ? '原声' : musicTitle.trim();
    final author = musicAuthor.trim().isEmpty ? '未知' : musicAuthor.trim();
    return '$title - $author';
  }

  String get firstPlayUrl => playUrls.isEmpty ? '' : playUrls.first;

  bool get isPlayable => firstPlayUrl.isNotEmpty;
}
