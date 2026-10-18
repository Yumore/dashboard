import 'package:dashboard/features/comic/hakacomic/haka_comics.dart';

/// `GET comics` payload (`haka_comic/lib/network/models.dart:282-292`).
class HakaComicsResponse {
  const HakaComicsResponse({required this.comics});

  final HakaComics comics;

  /// Used by the upstream controller to clear the list when the sort changes
  /// (`haka_comic/lib/views/comics/comics.dart:143`).
  static const HakaComicsResponse empty = HakaComicsResponse(
    comics: HakaComics(docs: [], limit: 0, page: 0, pages: 0, total: 0),
  );

  factory HakaComicsResponse.fromJson(Map<String, dynamic> json) {
    return HakaComicsResponse(
      comics: HakaComics.fromJson(json['comics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'comics': comics.toJson()};
}
