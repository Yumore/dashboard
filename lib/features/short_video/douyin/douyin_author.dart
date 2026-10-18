import 'package:dashboard/features/short_video/douyin/douyin_cover.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 作品作者（`Douyin.Dart` 的 `Author`）。
class DouyinAuthor {
  const DouyinAuthor({
    this.uid = '',
    this.uniqueId = '',
    this.nickname = '',
    this.signature = '',
    this.avatar = DouyinCover.empty,
  });

  factory DouyinAuthor.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinAuthor(
      uid: DouyinJson.asString(map['uid']),
      uniqueId: DouyinJson.asString(map['unique_id']),
      nickname: DouyinJson.asString(map['nickname']),
      signature: DouyinJson.asString(map['signature']),
      avatar: DouyinCover.fromJson(map['avatar_medium']),
    );
  }

  final String uid;
  final String uniqueId;
  final String nickname;
  final String signature;
  final DouyinCover avatar;

  /// 播放页左上角的 `@handle`：源工程取 `unique_id`，没有时退回昵称。
  String get handle {
    if (uniqueId.isNotEmpty) {
      return '@$uniqueId';
    }
    if (nickname.isNotEmpty) {
      return '@$nickname';
    }
    return '@未知用户';
  }

  String get displayName => nickname.isNotEmpty ? nickname : handle;

  String get avatarUrl => avatar.firstUrl;
}
