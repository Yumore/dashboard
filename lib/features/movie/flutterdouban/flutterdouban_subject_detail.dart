import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_summary.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_images.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_rating.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_trailer.dart';

/// `/v2/movie/subject/{id}` — the source's `MovieDetailBean`
/// (`lib/pages/detail/detail_page.dart` rendered exactly these fields).
///
/// The subject-level fields are delegated to [subject] so summary rows and the
/// detail header share one mapper. The ported `mock/subject_26266893.json`
/// does carry `summary` (plus `wish_count`, `trailers`, `popular_comments`),
/// but shorter payloads may omit it, so [hasSummary] guards the UI.
class FlutterDouBanSubjectDetail {
  const FlutterDouBanSubjectDetail({
    required this.subject,
    this.summary = '',
    this.tags = const <String>[],
    this.countries = const <String>[],
    this.languages = const <String>[],
    this.writers = const <FlutterDouBanCelebritySummary>[],
    this.wishCount = 0,
    this.reviewsCount = 0,
    this.photosCount = 0,
    this.pubdate = '',
    this.website = '',
    this.doubanSite = '',
    this.mobileUrl = '',
    this.shareUrl = '',
    this.scheduleUrl = '',
    this.hasTicket = false,
    this.hasSchedule = false,
    this.seasonsCount,
    this.episodesCount,
    this.trailers = const <FlutterDouBanTrailer>[],
    this.bloopers = const <FlutterDouBanTrailer>[],
    this.videos = const <FlutterDouBanTrailer>[],
    this.popularComments = const <FlutterDouBanComment>[],
  });

  factory FlutterDouBanSubjectDetail.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanSubjectDetail(
        subject: FlutterDouBanSubject.fromJson(json),
        summary: FlutterDouBanJson.asString(json['summary']).trim(),
        tags: FlutterDouBanJson.asStringList(json['tags']),
        countries: FlutterDouBanJson.asStringList(json['countries']),
        languages: FlutterDouBanJson.asStringList(json['languages']),
        writers: FlutterDouBanCelebritySummary.listFrom(json['writers']),
        wishCount: FlutterDouBanJson.asInt(json['wish_count']),
        reviewsCount: FlutterDouBanJson.asInt(json['reviews_count']),
        photosCount: FlutterDouBanJson.asInt(json['photos_count']),
        pubdate: FlutterDouBanJson.asString(json['pubdate']).trim(),
        website: FlutterDouBanJson.asString(json['website']).trim(),
        doubanSite: FlutterDouBanJson.asString(json['douban_site']).trim(),
        mobileUrl: FlutterDouBanJson.asString(json['mobile_url']).trim(),
        shareUrl: FlutterDouBanJson.asString(json['share_url']).trim(),
        scheduleUrl: FlutterDouBanJson.asString(json['schedule_url']).trim(),
        hasTicket: FlutterDouBanJson.asBool(json['has_ticket']),
        hasSchedule: FlutterDouBanJson.asBool(json['has_schedule']),
        seasonsCount: FlutterDouBanJson.asNullableInt(json['seasons_count']),
        episodesCount: FlutterDouBanJson.asNullableInt(json['episodes_count']),
        trailers: FlutterDouBanTrailer.listFrom(json['trailers']),
        bloopers: FlutterDouBanTrailer.listFrom(json['bloopers']),
        videos: FlutterDouBanTrailer.listFrom(json['videos']),
        popularComments: FlutterDouBanComment.listFrom(
          json['popular_comments'],
        ),
      );

  final FlutterDouBanSubject subject;
  final String summary;
  final List<String> tags;
  final List<String> countries;
  final List<String> languages;
  final List<FlutterDouBanCelebritySummary> writers;
  final int wishCount;
  final int reviewsCount;
  final int photosCount;
  final String pubdate;
  final String website;
  final String doubanSite;
  final String mobileUrl;
  final String shareUrl;
  final String scheduleUrl;
  final bool hasTicket;
  final bool hasSchedule;
  final int? seasonsCount;
  final int? episodesCount;
  final List<FlutterDouBanTrailer> trailers;
  final List<FlutterDouBanTrailer> bloopers;
  final List<FlutterDouBanTrailer> videos;
  final List<FlutterDouBanComment> popularComments;

  String get id => subject.id;
  String get title => subject.title;

  /// `标题 (2019)`, same format the list rows use.
  String get displayTitle => subject.displayTitle;

  String get originalTitle => subject.originalTitle;
  String get year => subject.year;
  String get alt => subject.alt;
  FlutterDouBanImages get images => subject.images;
  FlutterDouBanRating get rating => subject.rating;
  List<String> get genres => subject.genres;
  List<String> get casts => subject.casts.map((item) => item.name).toList();
  List<FlutterDouBanCelebritySummary> get castMembers => subject.casts;
  List<FlutterDouBanCelebritySummary> get directors => subject.directors;
  int get collectCount => subject.collectCount;
  List<String> get pubdates => subject.pubdates;
  List<String> get durations => subject.durations;
  bool get hasVideo => subject.hasVideo;

  /// `<summary>` is present in `mock/subject_26266893.json` but can be absent
  /// on terse list-derived payloads, so the UI must tolerate an empty string.
  bool get hasSummary => summary.isNotEmpty;

  String get genresText => genres.join(' / ');

  String get durationsText => durations.join(' / ');

  String get pubdatesText =>
      pubdates.where((item) => item.isNotEmpty).join(' / ');

  /// All watchable clips, in the order the source showed them
  /// (`trailers` first, then `bloopers`, then `videos`).
  List<FlutterDouBanTrailer> get allClips => <FlutterDouBanTrailer>[
    ...trailers,
    ...bloopers,
    ...videos,
  ];
}
