import 'package:dashboard/features/anime/animetrace/animetrace_play_status.dart';

/// A collected series (the source app's `Anime`).
///
/// [animeId] is 0 until the row has been inserted; the source app uses
/// `isCollected()` to mean "this row exists in the local database".
class AnimeTraceAnime {
  const AnimeTraceAnime({
    this.animeId = 0,
    required this.animeName,
    this.animeEpisodeCnt = 0,
    this.episodeStartNumber = 1,
    this.calEpisodeNumberFromOne = false,
    this.tagName = '',
    this.animeDesc = '',
    this.animeCoverUrl = '',
    this.rate = 0,
    this.checkedEpisodeCnt = 0,
    this.reviewNumber = 1,
    this.animeUrl = '',
    this.premiereTime = '',
    this.nameAnother = '',
    this.nameOri = '',
    this.authorOri = '',
    this.area = '',
    this.category = '',
    this.playStatus = '',
    this.productionCompany = '',
    this.officialSite = '',
    this.climbFinished = false,
    this.tempInfo,
    this.hasJoinedSeries = false,
  });

  final int animeId;
  final String animeName;

  /// Total episode count. `-1` means "unknown / never scraped".
  final int animeEpisodeCnt;

  /// Episode number the first episode of the series is labelled with.
  final int episodeStartNumber;

  /// When true, episode numbers are shown 1-based regardless of
  /// [episodeStartNumber].
  final bool calEpisodeNumberFromOne;

  final String tagName;
  final String animeDesc;
  final String animeCoverUrl;

  /// Local, 0..10 user rating.
  final int rate;

  /// Completed episode count, computed from the history table (not stored on
  /// the `anime` row).
  final int checkedEpisodeCnt;

  /// Rewatch counter. Episode notes and history rows are keyed by
  /// `(anime_id, episode_number, review_number)`.
  final int reviewNumber;

  final String animeUrl;
  final String premiereTime;
  final String nameAnother;
  final String nameOri;
  final String authorOri;
  final String area;
  final String category;
  final String playStatus;
  final String productionCompany;
  final String officialSite;
  final bool climbFinished;

  /// Scratch field used by collectors (for example a douban user name); never
  /// persisted.
  final String? tempInfo;

  final bool hasJoinedSeries;

  DateTime? get premiereDateTime => DateTime.tryParse(premiereTime);

  AnimeTracePlayStatus get playStatusValue =>
      AnimeTracePlayStatus.fromText(playStatus);

  bool isCollected() => animeId > 0;

  /// "地区 / 类型 / 2023-10-05" summary line.
  String get infoFirstLine {
    final parts = <String>[];
    if (area.isNotEmpty) parts.add(area);
    if (category.isNotEmpty) parts.add(category);
    if (premiereTime.isNotEmpty && premiereTime != 'null') {
      parts.add(premiereTime);
    }
    return parts.join(' / ');
  }

  /// "12集 • 连载中" summary line.
  String get infoSecondLine {
    final parts = <String>['$animeEpisodeCnt集'];
    final status = playStatusValue;
    if (status != AnimeTracePlayStatus.unknown) parts.add(status.label);
    return parts.join(' • ');
  }

  /// Absolute path for a cover that may be either a network URL or a path
  /// relative to the user's cover folder.
  String commonCoverUrl(String Function(String relative) toAbsolute) {
    if (animeCoverUrl.isEmpty) return '';
    if (animeCoverUrl.startsWith('http')) return animeCoverUrl;
    return toAbsolute(animeCoverUrl);
  }

  AnimeTraceAnime copyWith({
    int? animeId,
    String? animeName,
    int? animeEpisodeCnt,
    int? episodeStartNumber,
    bool? calEpisodeNumberFromOne,
    String? tagName,
    String? animeDesc,
    String? animeCoverUrl,
    int? rate,
    int? checkedEpisodeCnt,
    int? reviewNumber,
    String? animeUrl,
    String? premiereTime,
    String? nameAnother,
    String? nameOri,
    String? authorOri,
    String? area,
    String? category,
    String? playStatus,
    String? productionCompany,
    String? officialSite,
    bool? climbFinished,
    String? tempInfo,
    bool? hasJoinedSeries,
  }) {
    return AnimeTraceAnime(
      animeId: animeId ?? this.animeId,
      animeName: animeName ?? this.animeName,
      animeEpisodeCnt: animeEpisodeCnt ?? this.animeEpisodeCnt,
      episodeStartNumber: episodeStartNumber ?? this.episodeStartNumber,
      calEpisodeNumberFromOne:
          calEpisodeNumberFromOne ?? this.calEpisodeNumberFromOne,
      tagName: tagName ?? this.tagName,
      animeDesc: animeDesc ?? this.animeDesc,
      animeCoverUrl: animeCoverUrl ?? this.animeCoverUrl,
      rate: rate ?? this.rate,
      checkedEpisodeCnt: checkedEpisodeCnt ?? this.checkedEpisodeCnt,
      reviewNumber: reviewNumber ?? this.reviewNumber,
      animeUrl: animeUrl ?? this.animeUrl,
      premiereTime: premiereTime ?? this.premiereTime,
      nameAnother: nameAnother ?? this.nameAnother,
      nameOri: nameOri ?? this.nameOri,
      authorOri: authorOri ?? this.authorOri,
      area: area ?? this.area,
      category: category ?? this.category,
      playStatus: playStatus ?? this.playStatus,
      productionCompany: productionCompany ?? this.productionCompany,
      officialSite: officialSite ?? this.officialSite,
      climbFinished: climbFinished ?? this.climbFinished,
      tempInfo: tempInfo ?? this.tempInfo,
      hasJoinedSeries: hasJoinedSeries ?? this.hasJoinedSeries,
    );
  }

  /// Column names are snake_case, matching the source app's shipped schema so
  /// an exported `anime_trace.db` stays readable.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'anime_id': animeId,
      'anime_name': animeName,
      'anime_episode_cnt': animeEpisodeCnt,
      'episode_start_number': episodeStartNumber,
      'cal_episode_number_from_one': calEpisodeNumberFromOne ? 1 : 0,
      'tag_name': tagName,
      'anime_desc': animeDesc,
      'anime_cover_url': animeCoverUrl,
      'rate': rate,
      'review_number': reviewNumber,
      'anime_url': animeUrl,
      'premiere_time': premiereTime,
      'name_another': nameAnother,
      'name_ori': nameOri,
      'author_ori': authorOri,
      'area': area,
      'category': category,
      'play_status': playStatus,
      'production_company': productionCompany,
      'official_site': officialSite,
      'climb_finished': climbFinished ? 1 : 0,
    };
  }

  factory AnimeTraceAnime.fromMap(Map<String, Object?> map) {
    int intOf(String key, [int fallback = 0]) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    String stringOf(String key, [String fallback = '']) {
      final value = map[key];
      return value is String ? value : fallback;
    }

    return AnimeTraceAnime(
      animeId: intOf('anime_id'),
      animeName: stringOf('anime_name'),
      animeEpisodeCnt: intOf('anime_episode_cnt'),
      episodeStartNumber: intOf('episode_start_number', 1),
      calEpisodeNumberFromOne: intOf('cal_episode_number_from_one') != 0,
      tagName: stringOf('tag_name'),
      animeDesc: stringOf('anime_desc'),
      animeCoverUrl: stringOf('anime_cover_url'),
      rate: intOf('rate'),
      checkedEpisodeCnt: intOf('checked_episode_cnt'),
      reviewNumber: intOf('review_number', 1),
      animeUrl: stringOf('anime_url'),
      premiereTime: stringOf('premiere_time'),
      nameAnother: stringOf('name_another'),
      nameOri: stringOf('name_ori'),
      authorOri: stringOf('author_ori'),
      area: stringOf('area'),
      category: stringOf('category'),
      playStatus: stringOf('play_status'),
      productionCompany: stringOf('production_company'),
      officialSite: stringOf('official_site'),
      climbFinished: intOf('climb_finished') != 0,
    );
  }

  @override
  String toString() =>
      'AnimeTraceAnime(id=$animeId, name=$animeName, '
      'episodeCnt=$animeEpisodeCnt, url=$animeUrl)';
}
