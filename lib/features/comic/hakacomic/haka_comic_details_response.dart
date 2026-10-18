import 'package:dashboard/features/comic/hakacomic/haka_comic.dart';

/// `GET comics/{id}` payload (`haka_comic/lib/network/models.dart:426-436`).
class HakaComicDetailsResponse {
  const HakaComicDetailsResponse({required this.comic});

  final HakaComic comic;

  factory HakaComicDetailsResponse.fromJson(Map<String, dynamic> json) {
    return HakaComicDetailsResponse(
      comic: HakaComic.fromJson(json['comic'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'comic': comic.toJson()};
}
