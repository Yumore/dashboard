import 'package:dashboard/features/anime/animeone/animeone_url.dart';

/// 本地观看进度记录，字段与源应用 WatchEntry 一致。
class AnimeOneWatchEntry {
  AnimeOneWatchEntry({
    required this.episodeLink,
    required this.episodeName,
    this.positionSec = 0,
    this.durationSec = 0,
    this.done = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory AnimeOneWatchEntry.fromJson(Map<String, dynamic> json) =>
      AnimeOneWatchEntry(
        episodeLink: '${json['episodeLink']}',
        episodeName: '${json['episodeName']}',
        positionSec: json['positionSec'] as int? ?? 0,
        durationSec: json['durationSec'] as int? ?? 0,
        done: json['done'] as bool? ?? false,
        updatedAt: DateTime.tryParse('${json['updatedAt']}'),
      );

  final String episodeLink;
  final String episodeName;
  int positionSec;
  int durationSec;
  bool done;
  final DateTime updatedAt;

  /// 观看进度（0 ~ 1），未知总时长时返回 0。
  double get progress => durationSec > 0 ? positionSec / durationSec : 0.0;

  /// 观看百分比文案，未知总时长时按已看时长展示。
  String get progressLabel {
    if (durationSec > 0) return '${(progress * 100).toStringAsFixed(0)}%';
    return done ? '已看完' : '${(positionSec ~/ 60).toString().padLeft(2, '0')}分';
  }

  Map<String, dynamic> toJson() => {
    'episodeLink': episodeLink,
    'episodeName': episodeName,
    'positionSec': positionSec,
    'durationSec': durationSec,
    'done': done,
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// 补全为绝对链接，便于比对。
  static String absoluteLink(String link) => AnimeOneUrl.absolute(link);
}
