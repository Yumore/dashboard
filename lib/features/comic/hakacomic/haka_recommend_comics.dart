import 'package:dashboard/features/comic/hakacomic/haka_recommend_comic.dart';

/// `GET comics/{id}/recommendation` payload
/// (`haka_comic/lib/network/models.dart:546-556`).
class HakaRecommendComics {
  const HakaRecommendComics({required this.comics});

  final List<HakaRecommendComic> comics;

  factory HakaRecommendComics.fromJson(Map<String, dynamic> json) {
    return HakaRecommendComics(
      comics: (json['comics'] as List<dynamic>)
          .map(
            (item) =>
                HakaRecommendComic.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'comics': comics.map((comic) => comic.toJson()).toList(),
  };
}
