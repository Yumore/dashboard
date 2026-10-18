import 'package:dashboard/features/comic/hakacomic/haka_api.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';

/// One page image of a chapter (`haka_comic/lib/network/models.dart:1003-1026`).
class HakaChapterImage extends HakaImageBase {
  const HakaChapterImage({
    required this.uid,
    required this.id,
    required this.media,
  });

  @override
  final String uid;

  @override
  final String? id;

  final HakaImageDetail media;

  factory HakaChapterImage.fromJson(Map<String, dynamic> json) {
    return HakaChapterImage(
      uid: json['_id'] as String,
      id: json['id'] as String?,
      media: HakaImageDetail.fromJson(json['media'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': uid,
    'id': id,
    'media': media.toJson(),
  };

  /// Defaults to the public picacomic file server.
  @override
  String get url => media.directUrl;

  /// Host-aware variant used by the reader.
  String urlFor(HakaApi api) => media.urlFor(api);

  @override
  String get cacheKey => media.cacheKey;
}
