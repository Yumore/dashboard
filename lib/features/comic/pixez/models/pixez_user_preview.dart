import '../pixez_json.dart';
import 'pixez_illust.dart';
import 'pixez_user.dart';
import 'pixez_user_preview_novel.dart';

/// One entry of `/v1/search/user` `user_previews`.
class PixezUserPreview {
  const PixezUserPreview({
    required this.user,
    required this.illusts,
    required this.novels,
    required this.isMuted,
  });

  final PixezUser user;
  final List<PixezIllust> illusts;
  final List<PixezUserPreviewNovel> novels;
  final bool isMuted;

  factory PixezUserPreview.fromJson(Map<String, dynamic> json) {
    return PixezUserPreview(
      user: PixezUser.fromJson(pixezMap(json['user'])),
      illusts: [
        for (final illust in pixezMapList(json['illusts']))
          PixezIllust.fromJson(illust),
      ],
      novels: [
        for (final novel in pixezMapList(json['novels']))
          PixezUserPreviewNovel.fromJson(novel),
      ],
      isMuted: pixezBool(json['is_muted']),
    );
  }
}
