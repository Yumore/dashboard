import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';

/// Query of `GET users/favourite` (`haka_comic/lib/network/models.dart:890-898`).
class HakaUserFavoritePayload {
  const HakaUserFavoritePayload({required this.page, required this.sort});

  final int page;

  final HakaComicSortType sort;

  Map<String, dynamic> toJson() => {'page': page, 's': sort.name};
}
