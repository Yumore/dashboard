import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_summary.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_images.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_rating.dart';

/// A douban subject as returned inside list/search payloads.
///
/// Field names are the real douban ones: `original_title`, `subtype`,
/// `collect_count`, `mainland_pubdate`, `has_video`, `pubdates`, `durations`.
class FlutterDouBanSubject {
  const FlutterDouBanSubject({
    this.id = '',
    this.title = '',
    this.originalTitle = '',
    this.year = '',
    this.subtype = '',
    this.alt = '',
    this.images = const FlutterDouBanImages(),
    this.rating = const FlutterDouBanRating(),
    this.genres = const <String>[],
    this.casts = const <FlutterDouBanCelebritySummary>[],
    this.directors = const <FlutterDouBanCelebritySummary>[],
    this.collectCount = 0,
    this.pubdates = const <String>[],
    this.durations = const <String>[],
    this.mainlandPubdate = '',
    this.hasVideo = false,
  });

  factory FlutterDouBanSubject.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanSubject(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        title: FlutterDouBanJson.asString(json['title']).trim(),
        originalTitle: FlutterDouBanJson.asString(
          json['original_title'],
        ).trim(),
        year: FlutterDouBanJson.asString(json['year']).trim(),
        subtype: FlutterDouBanJson.asString(json['subtype']).trim(),
        alt: FlutterDouBanJson.asString(json['alt']).trim(),
        images: FlutterDouBanImages.fromJson(
          FlutterDouBanJson.asMapOrNull(json['images']),
        ),
        rating: FlutterDouBanRating.fromJson(
          FlutterDouBanJson.asMapOrNull(json['rating']),
        ),
        genres: FlutterDouBanJson.asStringList(json['genres']),
        casts: FlutterDouBanCelebritySummary.listFrom(json['casts']),
        directors: FlutterDouBanCelebritySummary.listFrom(json['directors']),
        collectCount: FlutterDouBanJson.asInt(json['collect_count']),
        pubdates: FlutterDouBanJson.asStringList(json['pubdates']),
        durations: FlutterDouBanJson.asStringList(json['durations']),
        mainlandPubdate: FlutterDouBanJson.asString(
          json['mainland_pubdate'],
        ).trim(),
        hasVideo: FlutterDouBanJson.asBool(json['has_video']),
      );

  static List<FlutterDouBanSubject> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanSubject.fromJson).toList(growable: false);

  final String id;
  final String title;
  final String originalTitle;
  final String year;
  final String subtype;
  final String alt;
  final FlutterDouBanImages images;
  final FlutterDouBanRating rating;
  final List<String> genres;
  final List<FlutterDouBanCelebritySummary> casts;
  final List<FlutterDouBanCelebritySummary> directors;
  final int collectCount;
  final List<String> pubdates;
  final List<String> durations;
  final String mainlandPubdate;
  final bool hasVideo;

  bool get isMovie => subtype == 'movie' || subtype.isEmpty;

  /// The source's `getType` (`lib/pages/search/search_page.dart:74-80`).
  String get typeLabel => subtype == 'movie' ? '电影' : subtype;

  /// `标题 (2019)`, the format the source search rows used.
  String get displayTitle => year.isEmpty ? title : '$title ($year)';

  String get genresText => genres.join(' / ');

  String get directorsText =>
      directors.map((director) => director.name).join(' / ');

  /// `豆瓣 7.9 分`, or an empty string when nobody rated it yet.
  String get ratingText =>
      rating.average == 0 ? '' : '豆瓣 ${rating.average.toStringAsFixed(1)} 分';

  String? get posterUrl => FlutterDouBanImage.resolve(images.preferred);
}
