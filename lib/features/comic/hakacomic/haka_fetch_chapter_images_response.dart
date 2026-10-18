import 'package:dashboard/features/comic/hakacomic/haka_chapter_episode.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapters_images.dart';

/// `comics/{id}/order/{order}/pages` payload
/// (`haka_comic/lib/network/models.dart:1069-1081`).
class HakaFetchChapterImagesResponse {
  const HakaFetchChapterImagesResponse({
    required this.pages,
    required this.ep,
  });

  final HakaChaptersImages pages;

  final HakaChapterEpisode ep;

  factory HakaFetchChapterImagesResponse.fromJson(Map<String, dynamic> json) {
    return HakaFetchChapterImagesResponse(
      pages: HakaChaptersImages.fromJson(
        json['pages'] as Map<String, dynamic>,
      ),
      ep: HakaChapterEpisode.fromJson(json['ep'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'pages': pages.toJson(), 'ep': ep.toJson()};
}
