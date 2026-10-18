import 'package:dashboard/features/comic/hakacomic/haka_search_comics.dart';

/// `POST comics/advanced-search` payload
/// (`haka_comic/lib/network/models.dart:877-888`).
class HakaSearchResponse {
  const HakaSearchResponse({required this.comics});

  final HakaSearchComics comics;

  static const HakaSearchResponse empty = HakaSearchResponse(
    comics: HakaSearchComics(docs: [], total: 0, limit: 0, page: 0, pages: 0),
  );

  factory HakaSearchResponse.fromJson(Map<String, dynamic> json) {
    return HakaSearchResponse(
      comics: HakaSearchComics.fromJson(json['comics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'comics': comics.toJson()};
}
