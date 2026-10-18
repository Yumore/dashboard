import 'package:dashboard/features/comic/hakacomic/haka_action_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_base_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_cache.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_categories_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapters.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapters_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_client.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_details_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_endpoints.dart';
import 'package:dashboard/features/comic/hakacomic/haka_fetch_chapter_images_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_fetch_chapter_images_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_hot_search_words_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_recommend_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_recommend_comics.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_comics.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_user_favorite_payload.dart';

/// Business layer over [HakaClient]: typed endpoints plus the two fan-out
/// paging rules of the picacomic schema.
///
/// Ported from `haka_comic/lib/network/http.dart`.
class HakaRepository {
  HakaRepository({required this.client, HakaCache? cache})
    : cache = cache ?? HakaCache();

  final HakaClient client;

  final HakaCache cache;

  /// Cache key used by [fetchHotSearchWords]
  /// (`haka_comic/lib/network/http.dart:372`).
  static const String hotSearchKey = 'keywords';

  /// `GET categories`, dropping web-only entries
  /// (`http.dart:40-55`).
  Future<List<HakaCategory>> fetchCategories() async {
    final json = await client.get(HakaEndpoints.categories);
    final response = HakaBaseResponse<HakaCategoriesResponse>.fromJson(
      json,
      (data) =>
          HakaCategoriesResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.categories
        .where((category) => category.isWeb != true)
        .toList();
  }

  /// `GET comics` with the payload as query string.
  Future<HakaComics> fetchComics(HakaComicsPayload payload) async {
    final json = await client.get(
      HakaEndpoints.comics,
      query: payload.toJson(),
    );
    final response = HakaBaseResponse<HakaComicsResponse>.fromJson(
      json,
      (data) => HakaComicsResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.comics;
  }

  /// `GET comics/{id}`.
  Future<HakaComic> fetchComicDetails(String id) async {
    final json = await client.get(HakaEndpoints.comicDetails(id));
    final response = HakaBaseResponse<HakaComicDetailsResponse>.fromJson(
      json,
      (data) =>
          HakaComicDetailsResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.comic;
  }

  /// Every chapter of a comic.
  ///
  /// Fetches `comics/{id}/eps?page=1` first, then fans out over
  /// `2..pages` and concatenates `docs` in page order
  /// (`haka_comic/lib/network/http.dart:76-105`).
  Future<List<HakaChapter>> fetchChapters(String id) async {
    final first = await _fetchChaptersPage(id, 1);
    if (first.pages <= 1) return first.docs;

    final rest = await Future.wait([
      for (var page = 2; page <= first.pages; page++)
        _fetchChaptersPage(id, page),
    ]);
    return [first.docs, ...rest.map((chapters) => chapters.docs)]
        .expand((docs) => docs)
        .toList();
  }

  Future<HakaChapters> _fetchChaptersPage(String id, int page) async {
    final json = await client.get(
      HakaEndpoints.comicChapters(id),
      query: {'page': page},
    );
    final response = HakaBaseResponse<HakaChaptersResponse>.fromJson(
      json,
      (data) => HakaChaptersResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.eps;
  }

  /// `GET comics/{id}/recommendation`.
  Future<List<HakaRecommendComic>> fetchComicRecommendation(String id) async {
    final json = await client.get(HakaEndpoints.comicRecommendation(id));
    final response = HakaBaseResponse<HakaRecommendComics>.fromJson(
      json,
      (data) => HakaRecommendComics.fromJson(data as Map<String, dynamic>),
    );
    return response.data.comics;
  }

  /// `POST comics/{id}/like`, returning the server-reported action.
  Future<String> likeComic(String id) async {
    final json = await client.post(HakaEndpoints.comicLike(id));
    final response = HakaBaseResponse<HakaActionResponse>.fromJson(
      json,
      (data) => HakaActionResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.action;
  }

  /// `POST comics/{id}/favourite`, returning the server-reported action.
  Future<String> favoriteComic(String id) async {
    final json = await client.post(HakaEndpoints.comicFavourite(id));
    final response = HakaBaseResponse<HakaActionResponse>.fromJson(
      json,
      (data) => HakaActionResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.action;
  }

  /// `POST comics/advanced-search?page=N` with the filters as body.
  Future<HakaSearchComics> searchComics(HakaSearchPayload payload) async {
    final json = await client.post(
      HakaEndpoints.searchComics(payload.page),
      data: payload.toJson(),
    );
    final response = HakaBaseResponse<HakaSearchResponse>.fromJson(
      json,
      (data) => HakaSearchResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.comics;
  }

  /// `GET users/favourite` with `page` + `s` query.
  Future<HakaComics> fetchFavoriteComics(HakaUserFavoritePayload payload) async {
    final json = await client.get(
      HakaEndpoints.favouriteComics,
      query: payload.toJson(),
    );
    final response = HakaBaseResponse<HakaComicsResponse>.fromJson(
      json,
      (data) => HakaComicsResponse.fromJson(data as Map<String, dynamic>),
    );
    return response.data.comics;
  }

  /// Every page image of a chapter.
  ///
  /// Same `page=1` then `2..pages` fan-out as [fetchChapters]
  /// (`haka_comic/lib/network/http.dart:203-231`).
  Future<List<HakaImageBase>> fetchChapterImages(
    HakaFetchChapterImagesPayload payload,
  ) async {
    final first = await _fetchChapterImagesPage(payload, 1);
    if (first.pages.pages <= 1) return first.pages.docs;

    final rest = await Future.wait([
      for (var page = 2; page <= first.pages.pages; page++)
        _fetchChapterImagesPage(payload, page),
    ]);
    return [
      ...first.pages.docs,
      for (final images in rest) ...images.pages.docs,
    ];
  }

  Future<HakaFetchChapterImagesResponse> _fetchChapterImagesPage(
    HakaFetchChapterImagesPayload payload,
    int page,
  ) async {
    final json = await client.get(
      HakaEndpoints.chapterImages(payload.id, payload.order),
      query: {'page': page},
    );
    final response =
        HakaBaseResponse<HakaFetchChapterImagesResponse>.fromJson(
          json,
          (data) => HakaFetchChapterImagesResponse.fromJson(
            data as Map<String, dynamic>,
          ),
        );
    return response.data;
  }

  /// `GET keywords`, memoized in [cache]
  /// (`haka_comic/lib/network/http.dart:372-386`).
  Future<List<String>> fetchHotSearchWords() async {
    final cached = cache.get(hotSearchKey);
    if (cached != null) {
      return HakaBaseResponse<HakaHotSearchWordsResponse>.fromJson(
        cached,
        (data) =>
            HakaHotSearchWordsResponse.fromJson(data as Map<String, dynamic>),
      ).data.keywords;
    }
    final json = await client.get(HakaEndpoints.hotSearchWords);
    final response = HakaBaseResponse<HakaHotSearchWordsResponse>.fromJson(
      json,
      (data) =>
          HakaHotSearchWordsResponse.fromJson(data as Map<String, dynamic>),
    );
    cache.add(hotSearchKey, json);
    return response.data.keywords;
  }
}
