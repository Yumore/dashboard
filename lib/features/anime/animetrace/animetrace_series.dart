import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// A user-defined series (franchise) that groups several collected anime.
class AnimeTraceSeries {
  AnimeTraceSeries(
    this.id,
    this.name, {
    this.desc = '',
    this.coverUrl = '',
    this.createTime = '',
    this.updateTime = '',
    List<AnimeTraceAnime>? animes,
  }) : animes = animes ?? <AnimeTraceAnime>[];

  final int id;
  final String name;
  final String desc;
  final String coverUrl;
  final String createTime;
  final String updateTime;

  /// Populated lazily by the series DAO when the detail page needs it.
  final List<AnimeTraceAnime> animes;

  /// Sentinel used by "add to series" pickers.
  factory AnimeTraceSeries.none() => AnimeTraceSeries(-1, '');

  bool get isNone => id == -1 && name.isEmpty;

  bool get isValid => !isNone;

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'name': name,
    'desc': desc,
    'cover_url': coverUrl,
    'create_time': createTime,
    'update_time': updateTime,
  };

  factory AnimeTraceSeries.fromMap(Map<String, Object?> map) {
    int intOf(Object? value) =>
        value is int ? value : int.tryParse('$value') ?? 0;
    String stringOf(Object? value) => value is String ? value : '';
    return AnimeTraceSeries(
      intOf(map['id']),
      stringOf(map['name']),
      desc: stringOf(map['desc']),
      coverUrl: stringOf(map['cover_url']),
      createTime: stringOf(map['create_time']),
      updateTime: stringOf(map['update_time']),
    );
  }

  @override
  String toString() => 'AnimeTraceSeries($id, $name, animes=${animes.length})';
}
